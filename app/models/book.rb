class Book < ApplicationRecord
    has_many :book_copies, dependent: :destroy
    has_many :book_inventories
    has_many :libraries, through: :book_inventories

    validates :title, presence: true, length: { minimum: 3 }
    validates :author, presence: true
    validates :isbn, presence: true, uniqueness: true, format: { with: /\A\d{10}(\d{3})?\z/, message: "must be 10 or 13 digits" }


    def find_available_copy
        book_copies.find_by(is_available: true, is_damaged: false)
    end
end
