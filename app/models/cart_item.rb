class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :book

  validates :quantity, numericality: { greater_than: 0 }
end
