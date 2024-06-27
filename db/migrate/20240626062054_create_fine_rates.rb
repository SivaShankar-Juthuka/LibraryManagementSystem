class CreateFineRates < ActiveRecord::Migration[7.1]
  def change
    create_table :fine_rates do |t|
      t.references :library, null: false, foreign_key: true
      t.string :fine_type
      t.float :fine_amount

      t.timestamps
    end
  end
end
