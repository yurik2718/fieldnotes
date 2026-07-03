class FieldItem < ApplicationRecord
  include Positioned

  belongs_to :field_series, touch: true

  has_one_attached :photo do |attachable|
    attachable.variant :thumb,  resize_to_fill:  [ 400,  300 ], format: :avif, saver: { quality: 75 }
    attachable.variant :medium, resize_to_limit: [ 800,  600 ], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [ 1920, 1440 ], format: :avif, saver: { quality: 88 }
    attachable.variant :retina, resize_to_limit: [ 2560, 1920 ], format: :avif, saver: { quality: 85 }
  end

  has_one_attached :watermarked_photo do |attachable|
    attachable.variant :medium, resize_to_limit: [ 800,  600 ], format: :avif, saver: { quality: 80 }
    attachable.variant :full,   resize_to_limit: [ 1920, 1440 ], format: :avif, saver: { quality: 88 }
    attachable.variant :retina, resize_to_limit: [ 2560, 1920 ], format: :avif, saver: { quality: 85 }
  end

  enum :kind, %w[ photo video ].index_by(&:itself), default: :photo, validate: true

  validates :youtube_url, presence: true, if: :video?

  def youtube_video_id
    youtube_url&.match(/(?:v=|youtu\.be\/)([^&?\s]+)/)&.captures&.first
  end

  private
    def positioning_scope = field_series.field_items
end
