class CreateFines < ActiveRecord::Migration[7.1]
  def change
    create_table :fines do |t|
      t.references :member, null: false, foreign_key: true
      t.references :borrow, null: false, foreign_key: true
      t.float :fine_amount
      t.string :paid_status
      t.datetime :paid_date
      t.datetime :due_date

      t.timestamps
    end
  end
end
