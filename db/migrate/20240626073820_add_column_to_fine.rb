class AddColumnToFine < ActiveRecord::Migration[7.1]
  def change
    add_column :fines, :fine_type, :string
  end
end
