class Essay < ApplicationRecord
  include HasCover, Sluggable

  has_rich_text :content

  enum :status, %w[ draft published ].index_by(&:itself), default: :draft, validate: true

  before_save :set_published_at

  validates :title, presence: true

  scope :ordered, -> { order(published_at: :desc) }

  def reading_time
    words = content.to_plain_text.split.size
    (words / 200.0).ceil.clamp(1, 60)
  end

  private
    def set_published_at
      self.published_at = Time.current if published? && published_at.blank?
    end
end
