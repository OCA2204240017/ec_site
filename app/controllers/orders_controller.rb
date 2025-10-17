class OrdersController < ApplicationController
  before_action :require_login

  def create
    cart = current_user.cart
    return redirect_to cart_path, alert: 'カートが空です' unless cart&.cart_items&.any?

    order = current_user.orders.create!(total_cents: cart.cart_items.sum { |ci| ci.quantity * (ci.book.price || 0) })
    cart.cart_items.each do |ci|
      order.order_items.create!(book: ci.book, quantity: ci.quantity, unit_price_cents: (ci.book.price || 0))
    end
    cart.cart_items.destroy_all
    OrderMailer.confirmation(order).deliver_later
    redirect_to order_path(order), notice: '購入が完了しました'
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
