class PageView < ApplicationRecord
  validates :event, presence: true

  def self.prune = where(created_at: ...1.year.ago).in_batches.delete_all
end
