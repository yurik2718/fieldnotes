class FieldSeries < ApplicationRecord
  include HasCover, Sluggable

  has_many :field_items, dependent: :destroy

  enum :kind, %w[ photo video mixed ].index_by(&:itself), default: :photo, validate: true

  validates :title, presence: true

  def cover_photo
    cover.attached? ? cover : field_items.find { it.photo.attached? }&.photo
  end

  def append_photos(photos)
    photos.each { field_items.create!(photo: it) }
  end
end
