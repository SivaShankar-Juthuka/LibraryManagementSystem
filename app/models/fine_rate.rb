# app/models/fine_rate.rb
class FineRate < ApplicationRecord
    belongs_to :library
  
    validates :fine_type, presence: true, inclusion: { in: %w[overdue damaged] }, uniqueness: {scope: :library_id, message: "should be unique per library" }
    validates :fine_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
  