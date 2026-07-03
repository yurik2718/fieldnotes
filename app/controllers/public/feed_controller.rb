class Public::FeedController < Public::BaseController
  def index
    @essays = Essay.published.ordered.includes(:rich_text_content, :cover_attachment).limit(20)
    @series = FieldSeries.order(created_at: :desc).limit(10)
    fresh_when etag: [ @essays, @series ]

    respond_to do |format|
      format.html
      format.rss
    end
  end
end
