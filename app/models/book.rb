require "net/http"

class Book < ApplicationRecord
  OPEN_LIBRARY_URL   = "https://openlibrary.org/api/books"
  COVER_URL_TEMPLATE = "https://covers.openlibrary.org/b/isbn/%s-L.jpg"

  has_rich_text :review

  enum :status, %w[ reading completed abandoned ].index_by(&:itself), default: :reading, validate: true

  before_validation :fetch_metadata_from_isbn, on: :create

  validates :title,  presence: true
  validates :author, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :by_year, -> { order(year_read: :desc) }

  def self.lookup_isbn(isbn)
    Rails.cache.fetch("open_library:#{isbn}", expires_in: 7.days, skip_nil: true) do
      resp = Net::HTTP.get_response(URI("#{OPEN_LIBRARY_URL}?bibkeys=ISBN:#{isbn}&format=json&jscmd=data"))

      if resp.is_a?(Net::HTTPSuccess) && (book = JSON.parse(resp.body)["ISBN:#{isbn}"]).present?
        {
          title:     book["title"],
          author:    book.dig("authors", 0, "name"),
          cover_url: COVER_URL_TEMPLATE % isbn
        }
      end
    end
  rescue => e
    Rails.logger.error("Book.lookup_isbn error: #{e.message}")
    nil
  end

  def cover_image_url
    return cover_url if cover_url.present?

    "https://covers.openlibrary.org/b/isbn/#{isbn}-L.jpg" if isbn.present?
  end

  private
    def fetch_metadata_from_isbn
      return if isbn.blank?

      data = self.class.lookup_isbn(isbn.strip)
      return unless data

      self.title     = data[:title]     if title.blank?
      self.author    = data[:author]    if author.blank?
      self.cover_url = data[:cover_url] if cover_url.blank?
    end
end
