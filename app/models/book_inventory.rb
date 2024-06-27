class BookInventory < ApplicationRecord
  belongs_to :book
  belongs_to :library

  def update_reserved_copies(increment)
    if increment
      update(copies_reserved: copies_reserved + 1)
    else
      update(copies_reserved: copies_reserved - 1)
    end
  end

  def update_inventory_on_borrow
    update(available_copies: available_copies - 1, copies_borrowed: copies_borrowed + 1)
  end

  def update_inventory_on_return
    update(available_copies: available_copies + 1, copies_borrowed: copies_borrowed - 1)
  end
end
