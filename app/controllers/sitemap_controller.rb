class SitemapController < ApplicationController
  allow_unauthenticated_access

  def index
    @essays = Essay.published.ordered
    @series = FieldSeries.order(created_at: :desc)
    @books  = Book.order(:id)

    expires_in 1.hour, public: true
  end
end
