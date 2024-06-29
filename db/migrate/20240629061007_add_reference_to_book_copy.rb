class AddReferenceToBookCopy < ActiveRecord::Migration[7.1]
  def change
    add_reference :book_copies, :library, null: false, foreign_key: true
  end
end
