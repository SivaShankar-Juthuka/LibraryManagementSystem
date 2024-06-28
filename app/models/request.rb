class Request < ApplicationRecord
  belongs_to :member
  belongs_to :book

  validates :requested_at, presence: true
  validates :is_approved, inclusion: { in: [true, false] }

  after_create :increment_reserved_copies
  after_update :create_borrow_record, if: :is_approved_changed_to_true?


  def self.create_request(member_id, book_id, library_id)
    member = Member.find_by(id: member_id)
    book = Book.find_by(id: book_id)
    library = Library.find_by(id: library_id)

    if member && book && library
      book_inventory = BookInventory.find_by(book_id: book.id, library_id: library.id)
      if book_inventory
        requested_at = Date.current
        request = Request.new(
          member_id: member.id,
          book_id: book.id,
          requested_at: requested_at
        )
        if request.save
          { success: true, request: request }
        else
          { success: false, error: request.errors.full_messages }
        end
      else
        { success: false, error: "Book not available in the specified library" }
      end
    else
      { success: false, error: "Member, Book, or Library not found" }
    end
  end

  def self.edit_request(request_id, member_id, params, current_user)
    member = Member.find_by(id: member_id)
    if member
        request = member.requests.find_by(id: request_id)
        if request
          if request.update(params)
            { success: true, request: request }
          else
            { success: false, error: request.errors.full_messages }
          end
        else
          { success: false, error: 'Request not found' }
        end
    else
      { success: false, error: 'Member not found' }
    end
  end

  private

  def is_approved_changed_to_true?
    saved_change_to_is_approved? && is_approved?
  end

  def create_borrow_record
    borrow = Borrow.new(
      member_id: member.id,
      book_id: book.id
    )
    if borrow.save
      decrement_reserved_copies
    else
      errors.add(:base, "Failed to create borrow record: #{borrow.errors.full_messages.join(', ')}")
      throw :abort
    end
  end

  def increment_reserved_copies
    book_inventory = BookInventory.find_by(book_id: book.id)
    if book_inventory
      book_inventory.update_reserved_copies(true)
    else
      errors.add(:base, "Error processing the book request due to missing inventory record")
      throw :abort
    end
  end

  def decrement_reserved_copies
    book_inventory = BookInventory.find_by(book_id: book.id)
    if book_inventory
      book_inventory.update_reserved_copies(false)
    else
      errors.add(:base, "Error processing the book request due to missing inventory record")
      throw :abort
    end
  end

  def self.ransackable_attributes
    %w[id member_id book_id requested_at is_approved]
  end

  def self.ransackable_associations
    %w[member book]
  end
end
