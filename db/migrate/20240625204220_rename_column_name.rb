class RenameColumnName < ActiveRecord::Migration[7.1]
  def change
    rename_column :fines, :paid_date, :paid_at
    
  end
end
