# app/api/entities/book_copy.rb
class Api::Entities::BookCopy < Grape::Entity
    expose :id, if: {type: :full}
    expose :book, using: Api::Entities::Book 
    expose :copy_number
    expose :is_damaged
    expose :is_available
end