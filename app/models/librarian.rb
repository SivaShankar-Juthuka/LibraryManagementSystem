class Librarian < ApplicationRecord
  belongs_to :user
  belongs_to :library

  validates :user_id, uniqueness: true

  def self.change_library(user_id, new_library_id)
    librarian = self.find_by(user_id: user_id)
    if librarian
      new_library = Library.find_by(id: new_library_id)
      if new_library
        librarian.update(library_id: new_library_id)
        librarian
      else
        raise ActiveRecord::RecordNotFound.new("New library not found")
      end
    else
      raise ActiveRecord::RecordNotFound.new("Librarian not found")
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id library_id user_id]
  end
end