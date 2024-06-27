class AddIsAvailableToBookCopy < ActiveRecord::Migration[7.1]
  def change
    add_column :book_copies, :is_available, :boolean, default: true
  end
end
