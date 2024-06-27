# app/api/entities/book_inventory.rb
class Api::Entities::BookInventory < Grape::Entity
    expose :id, if: {type: :full}
    expose :library, using: Api::Entities::Library do |bookinventory|
        bookinventory.library
    end
    expose :book, using: Api::Entities::Book do |bookinventory|
        bookinventory.book
    end

    expose :available_copies
    expose :copies_borrowed
    expose :copies_reserved
end