class AddColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_assigned, :boolean, default: false
  end
end
