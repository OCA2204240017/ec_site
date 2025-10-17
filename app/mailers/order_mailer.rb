class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    mail to: @order.user.email, subject: "注文確認 - 注文 ##{@order.id}"
  end
end
