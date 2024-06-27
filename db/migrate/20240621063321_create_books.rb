class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn
      t.datetime :published_at
      t.string :genre
      t.integer :copy_count

      t.timestamps
    end
  end
end
