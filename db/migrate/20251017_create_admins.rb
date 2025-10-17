class CreateAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :admin do |t|
      t.string :email, null: false
      t.string :password, null: false
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :updated_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :admin, :email, unique: true
    add_index :admin, :password, unique: true
  end
end
