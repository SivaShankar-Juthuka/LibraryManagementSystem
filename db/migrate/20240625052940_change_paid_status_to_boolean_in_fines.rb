class ChangePaidStatusToBooleanInFines < ActiveRecord::Migration[6.0]
  def change
    change_column :fines, :paid_status, :boolean, default: false
  end
end
