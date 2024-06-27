class AddLibraryReferenceToMembers < ActiveRecord::Migration[7.1]
  def change
    add_reference :members, :library, foreign_key: true
  end
end
