class Borrow < ApplicationRecord
  belongs_to :member
  belongs_to :book
  has_many :fines

  validates :member_id, :issued_copy, :borrowed_at, :due_date, presence: true
  validate :book_not_already_borrowed_by_member, on: :create
  validate :approved_request_exists, on: :create
  validate :borrow_limit_not_exceeded, on: :create

  before_validation :assign_issued_copy_and_dates, on: :create
  after_update :handle_returned_book, if: :saved_change_to_returned_at?

  def update_borrow_history(params)
    update_attributes = params.slice(:book_id, :returned_at)

    if update(update_attributes)
      update_book_copy(params[:is_damaged]) if params[:is_damaged].present?
      self
    else
      errors.add(:base, 'Failed to update borrow history')
      throw :abort
    end
  end

  private

  def update_book_copy(is_damaged)
    book_copy = BookCopy.find_by(copy_number: issued_copy)
    if book_copy
      book_copy.update(is_damaged: is_damaged)
    else
      errors.add(:base, 'Book copy not found')
      throw :abort
    end
  end

  def book_not_already_borrowed_by_member
    if Borrow.where(member_id: member_id, book_id: book_id, returned_at: nil).exists?
      errors.add(:base, "This book is already borrowed by you and hasn't been returned yet.")
    end
  end

  def approved_request_exists
    unless Request.where(member_id: member_id, book_id: book_id, is_approved: true).exists?
      errors.add(:base, "You must have an approved request before borrowing this book.")
    end
  end

  def borrow_limit_not_exceeded
    if member.borrowing_limit <= 0
      errors.add(:base, "You have reached your borrow limit. Please return a book before borrowing a new one.")
    end
  end

  def assign_issued_copy_and_dates
    request = Request.find_by(member_id: member_id, book_id: book_id, is_approved: true)
    if request.present?
      book_copy = book.book_copies.find_by(is_available: true, is_damaged: false)
      book_inventory = BookInventory.find_by(book_id: book.id)
      if book_copy && book_inventory && book_inventory.available_copies > 0
        self.issued_copy = book_copy.copy_number
        self.borrowed_at ||= Time.current
        self.due_date ||= 1.week.from_now
        book_copy.update_availability(false)
        book_inventory.update_inventory_on_borrow
        member.decrement_borrow_limit
      else
        errors.add(:base, "No available book copy to borrow or insufficient inventory")
        throw :abort
      end
    else
      errors.add(:base, "You must have an approved request before borrowing this book.")
      throw :abort
    end
  end

  def handle_returned_book
    book_copy = BookCopy.find_by(copy_number: issued_copy)
    book_inventory = BookInventory.find_by(book_id: book.id)
    
    if book_copy && book_inventory
      if book_copy.is_damaged
        Fine.create_fine_for_damaged(self)
        book_copy.update_availability(false)
      else
        Fine.create_fine_if_overdue(self)
      end
      
      book_inventory.update_inventory_on_return
      member.increment_borrow_limit
    else
      errors.add(:base, "Error processing the returned book")
      throw :abort
    end
  end
end