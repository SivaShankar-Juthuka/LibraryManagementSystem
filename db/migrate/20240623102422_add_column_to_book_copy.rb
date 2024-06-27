class AddColumnToBookCopy < ActiveRecord::Migration[7.1]
  def change
    add_column :book_copies, :copy_number, :integer
  end
end
