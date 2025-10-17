
class Book < ApplicationRecord
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags

  validates :title, presence: true
  validates :author, presence: true
end
