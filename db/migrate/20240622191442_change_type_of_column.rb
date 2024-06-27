class ChangeTypeOfColumn < ActiveRecord::Migration[7.1]
  def change
    change_column :books, :published_at, :integer
  end
end
