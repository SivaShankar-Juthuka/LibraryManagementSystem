class AddColumnToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :copy_count, :integer
  end
end
