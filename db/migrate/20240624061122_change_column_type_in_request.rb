class ChangeColumnTypeInRequest < ActiveRecord::Migration[7.1]
  def change
    # rename the status in requests to is_approved
    rename_column :requests, :status, :is_approved
    # change the type of is_approved to boolean
    change_column :requests, :is_approved, :boolean, default: false
  end
end
