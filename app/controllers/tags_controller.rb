class TagsController < ApplicationController
  before_action :require_login

  def show
    @tag = Tag.find(params[:id])
    @books = @tag.books
    render 'books/index'
  end
end

