class Public::BooksController < Public::BaseController
  def index
    @reading = Book.reading.by_year
    @books   = Book.completed.by_year
    fresh_when etag: [ Book.maximum(:updated_at), Book.count ]
  end

  def show
    @book = Book.find(params[:id])
    fresh_when @book
  end
end
