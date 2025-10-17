require 'bcrypt'
require 'securerandom'

class MigratePasswordsToDigest < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string
    end

    say_with_time "Backfilling password_digest from password (bcrypt)" do
      require 'bcrypt'
      User.reset_column_information
      User.find_each do |u|
        # skip if already has digest
        if u.respond_to?(:password_digest) && u.password_digest.present?
          next
        end

        if u.respond_to?(:password) && u.password.present?
          u.update_column(:password_digest, BCrypt::Password.create(u.password))
        else
          # fill with a random hash so NOT NULL constraint can be applied
          u.update_column(:password_digest, BCrypt::Password.create(SecureRandom.hex))
        end
      end
    end

    if column_exists?(:users, :password_digest)
      change_column_null :users, :password_digest, false
    end

    # remove plain password index and column if present
    if index_exists?(:users, :password)
      remove_index :users, :password
    end

    if column_exists?(:users, :password)
      remove_column :users, :password
    end
  end

  def down
    unless column_exists?(:users, :password)
      add_column :users, :password, :string
      add_index :users, :password, unique: true
    end

    # Note: can't recover plain passwords from digest
    raise ActiveRecord::IrreversibleMigration
  end
end
