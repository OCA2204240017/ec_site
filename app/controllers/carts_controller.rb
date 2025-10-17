class CartsController < ApplicationController
  before_action :require_login

  def show
    @cart = current_user.cart || current_user.create_cart
  end

  def add
    @cart = current_user.cart || current_user.create_cart
    book = Book.find(params[:book_id])
    item = @cart.cart_items.find_or_initialize_by(book: book)
    item.quantity += (params[:quantity] || 1).to_i
    item.save!
    redirect_to cart_path, notice: 'カートに追加しました'
  end

  def remove
    @cart = current_user.cart
    item = @cart.cart_items.find_by(id: params[:id])
    item.destroy if item
    redirect_to cart_path, notice: 'カートから削除しました'
  end
end
