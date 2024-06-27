class Library < ApplicationRecord
    has_many :book_inventories, dependent: :destroy
    has_many :librarians
    has_many :members
    has_many :fine_rates, dependent: :destroy

    def self.ransackable_attributes(_auth_object = nil)
        %w[id library_name library_address]
    end

    def self.ransackable_associations(_auth_object = nil)
        %w[book_inventories librarians members fine_rates]
    end
end
