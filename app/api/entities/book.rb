# app/api/entities/book.rb
class Api::Entities::Book < Grape::Entity
    expose :id, if: {type: :full}
    expose :title
    expose :author
    expose :genre
    expose :isbn
    expose :published_at
    expose :copy_count
end
    
