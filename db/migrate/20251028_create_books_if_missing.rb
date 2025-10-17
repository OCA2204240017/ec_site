class CreateBooksIfMissing < ActiveRecord::Migration[8.0]
  def up
    unless table_exists?(:books)
      create_table :books do |t|
        t.string :title, null: false
        t.string :author, null: false
        t.date :published_at
        t.integer :price
        t.string :status
        t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
      end
    end

    unless table_exists?(:tags)
      create_table :tags do |t|
        t.string :name, null: false
        t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
      end
      add_index :tags, :name, unique: true
    end

    unless table_exists?(:book_tags)
      create_table :book_tags do |t|
        t.references :book, null: false, foreign_key: true
        t.references :tag, null: false, foreign_key: true
        t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
      end
    end
  end

  def down
    # no-op to avoid accidental data loss
  end
end
