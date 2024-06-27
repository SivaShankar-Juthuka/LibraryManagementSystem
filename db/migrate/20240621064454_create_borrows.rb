class CreateBorrows < ActiveRecord::Migration[7.1]
  def change
    create_table :borrows do |t|
      t.references :member, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :issued_copy
      t.datetime :borrowed_at
      t.datetime :due_date
      t.datetime :returned_at

      t.timestamps
    end
  end
end
