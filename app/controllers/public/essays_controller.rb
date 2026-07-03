class Public::EssaysController < Public::BaseController
  def index
    @essays = Essay.published.ordered.includes(:cover_attachment)
    fresh_when @essays
  end

  def show
    @essay = Essay.published.find_by!(slug: params[:slug])
    Rails.event.notify("essay.viewed", essay_id: @essay.id, path: request.path)
    fresh_when @essay
  end
end
