require 'bcrypt'

class MigrateAdminPasswordsToDigest < ActiveRecord::Migration[8.0]
  def up
    add_column :admin, :password_digest, :string

    say_with_time "Backfilling admin password_digest from password (bcrypt)" do
      Admin.reset_column_information
      Admin.find_each do |a|
        if a.password.present?
          a.update_column(:password_digest, BCrypt::Password.create(a.password))
        else
          # If ENV provides credentials for admin, use it for matching email
          if ENV['ADMIN_EMAIL'] && ENV['ADMIN_PASSWORD'] && a.email == ENV['ADMIN_EMAIL']
            a.update_column(:password_digest, BCrypt::Password.create(ENV['ADMIN_PASSWORD']))
          else
            # fill with random hash so NOT NULL constraint can be applied; user must reset via admin UI
            a.update_column(:password_digest, BCrypt::Password.create(SecureRandom.hex))
          end
        end
      end
    end

    change_column_null :admin, :password_digest, false

    if index_exists?(:admin, :password)
      remove_index :admin, :password
    end

    if column_exists?(:admin, :password)
      remove_column :admin, :password
    end
  end

  def down
    add_column :admin, :password, :string
    add_index :admin, :password, unique: true
    raise ActiveRecord::IrreversibleMigration
  end
end
