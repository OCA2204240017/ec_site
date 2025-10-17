class BooksController < ApplicationController
  before_action :require_login

  def index
    @q = params[:q]
    @tag = Tag.find_by(id: params[:tag_id]) if params[:tag_id]

    @books = Book.all
    @books = @books.where('title LIKE ? OR author LIKE ?', "%#{@q}%", "%#{@q}%") if @q.present?
    @books = @books.joins(:tags).where(tags: { id: @tag.id }) if @tag
  end

  def show
    @book = Book.find(params[:id])
  end
end
