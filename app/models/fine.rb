class Fine < ApplicationRecord
  belongs_to :member
  belongs_to :borrow

  validates :fine_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :paid_status, inclusion: { in: [true, false] }
  validates :fine_type, presence: true, inclusion: { in: %w[overdue damaged] }

  before_create :set_default_paid_status
  before_update :set_paid_date, if: :paid_status_changed?

  def self.create_fine_if_overdue(borrow)
    library = borrow.book.book_inventories.first.library
    fine_rate = library.fine_rates.find_by(fine_type: 'overdue')
    if borrow.returned_at > borrow.due_date && fine_rate
      overdue_days = (borrow.returned_at.to_date - borrow.due_date.to_date).to_i
      fine_amount = overdue_days * fine_rate.fine_amount
      create(
        member: borrow.member,
        borrow: borrow,
        fine_amount: fine_amount,
        fine_type: 'overdue'
      )
    end
  end

  def self.create_fine_for_damaged(borrow)
    library = borrow.book.book_inventories.first.library
    fine_rate = library.fine_rates.find_by(fine_type: 'damaged')
    if fine_rate
      create(
        member: borrow.member,
        borrow: borrow,
        fine_amount: fine_rate.fine_amount,
        fine_type: 'damaged'
      )
    end
  end
  
  private

  def set_default_paid_status
    self.paid_status = false
    self.paid_at = nil
  end

  def set_paid_date
    self.paid_at = Time.current if paid_status
  end

  def self.ransackable_attributes(auth_object = nil)
    %i[id fine_amount paid_status paid_at fine_type]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[member borrow]
  end
end
