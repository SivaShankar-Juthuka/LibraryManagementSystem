# app/api/entities/borrow.rb
class Api::Entities::Borrow < Grape::Entity
    expose :id, if: {type: :full}
    expose :book, using: Api::Entities::Book do |borrow, options|
        borrow.book
    end
    expose :issued_copy
    expose :borrowed_at
    expose :returned_at
    expose :due_date
end