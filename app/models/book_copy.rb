class BookCopy < ApplicationRecord
  belongs_to :book

  validates :copy_number, presence: true, numericality: { only_integer: true }
  validates :is_damaged, inclusion: { in: [true, false] }
  validates :is_available, inclusion: { in: [true, false] }

  def update_availability(available)
    update(is_available: available)
  end
end
