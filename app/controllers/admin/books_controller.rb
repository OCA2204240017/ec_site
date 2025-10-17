module Admin
  class BooksController < ApplicationController
    layout 'admin'
    before_action :require_admin
    before_action :set_book, only: %i[show edit update destroy]

    def index
      @books = Book.all
    end

    def new
      @book = Book.new
    end

    def create
      @book = Book.new(book_params)
      if @book.save
        redirect_to admin_book_path(@book), notice: '書籍を作成しました'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end

    def edit; end

    def update
      if @book.update(book_params)
        redirect_to admin_book_path(@book), notice: '書籍を更新しました'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      redirect_to admin_books_path, notice: '書籍を削除しました'
    end

    private

    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :author, :published_at, :price, :status, tag_ids: [])
    end

    def require_admin
      redirect_to new_admin_session_path, alert: '管理者でログインしてください' unless session[:admin_id] && Admin.find_by(id: session[:admin_id])
    end
  end
end
