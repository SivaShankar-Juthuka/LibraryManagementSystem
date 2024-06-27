class CreateBookInventories < ActiveRecord::Migration[7.1]
  def change
    create_table :book_inventories do |t|
      t.references :book, null: false, foreign_key: true
      t.references :library, null: false, foreign_key: true
      t.integer :available_copies
      t.integer :copies_borrowed
      t.integer :copies_reserved

      t.timestamps
    end
  end
end
