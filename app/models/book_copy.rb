class BookCopy < ApplicationRecord
  belongs_to :book

  validates :copy_number, presence: true, numericality: { only_integer: true }
  validates :is_damaged, inclusion: { in: [true, false] }
  validates :is_available, inclusion: { in: [true, false] }

  def update_availability(available)
    update(is_available: available)
  end

  def self.ransackable_attributes(auth_object = nil)
    %i[id book_id copy_number is_damaged is_available]
  end

  def self.ransackable_associations(auth_object = nil)
    %i[book]
  end
end
