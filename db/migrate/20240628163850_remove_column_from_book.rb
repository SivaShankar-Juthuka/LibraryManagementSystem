class RemoveColumnFromBook < ActiveRecord::Migration[7.1]
  def change
    remove_column :books, :copy_count, :integer
  end
end
