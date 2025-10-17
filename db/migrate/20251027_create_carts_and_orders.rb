class CreateCartsAndOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_cents
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
