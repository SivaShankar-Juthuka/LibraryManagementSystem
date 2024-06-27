class Book < ApplicationRecord
    has_many :book_copies, dependent: :destroy
    has_many :book_inventories
    has_many :libraries, through: :book_inventories

    validates :title, presence: true, length: { minimum: 3 }
    validates :author, presence: true
    validates :isbn, presence: true, uniqueness: true, format: { with: /\A\d{10}(\d{3})?\z/, message: "must be 10 or 13 digits" }
    validates :published_at, presence: true
    validates :genre, presence: true
    validates :copy_count, presence: true

    def find_available_copy
        book_copies.find_by(is_available: true, is_damaged: false)
    end

    def self.ransackable_attributes(auth_object = nil)
        %w[title author isbn published_at genre copy_count]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[book_copies book_inventories libraries]
    end
end