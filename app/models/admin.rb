class Admin < ApplicationRecord
  self.table_name = 'admin'

  has_secure_password

  validates :email, presence: true, uniqueness: true
end
