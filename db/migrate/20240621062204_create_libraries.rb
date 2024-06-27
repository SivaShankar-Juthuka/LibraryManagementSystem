class CreateLibraries < ActiveRecord::Migration[7.1]
  def change
    create_table :libraries do |t|
      t.string :library_name
      t.string :library_address

      t.timestamps
    end
  end
end
