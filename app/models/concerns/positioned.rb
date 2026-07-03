module Positioned
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position) }

    before_create { self.position ||= (positioning_scope.maximum(:position) || 0) + 1 }
  end

  private
    def positioning_scope = self.class.all
end
