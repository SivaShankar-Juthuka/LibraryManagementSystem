class RemoveColumnFromFine < ActiveRecord::Migration[7.1]
  def change
    remove_column :fines, :due_date, :datetime
    change_column_default :fines, :paid_status, default: false
  end
end
