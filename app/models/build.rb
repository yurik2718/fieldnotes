class Build < ApplicationRecord
  include HasCover, Positioned, Sluggable

  enum :status, %w[ active paused completed archived ].index_by(&:itself), default: :active, validate: true
  enum :kind,   %w[ business oss media community other ].index_by(&:itself), default: :other, validate: true

  validates :title, presence: true
end
