class Member < ApplicationRecord
  belongs_to :user
  has_many :borrows
  has_many :requests
  has_many :fines
  belongs_to :library 

  def decrement_borrow_limit
    update(borrowing_limit: borrowing_limit - 1)
  end

  def increment_borrow_limit
    update(borrowing_limit: borrowing_limit + 1)
  end

  def self.ransackable_attributes(auth_object = nil)
      %w[id library_id borrowing_limit user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[borrows fines library requests user]
  end
end
