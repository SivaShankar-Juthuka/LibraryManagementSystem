# app/api/entities/request.rb
class Api::Entities::Request < Grape::Entity
    expose :id, if: {type: :full}
    expose :member, using: Api::Entities::Member do |request|
        request.member
    end
    expose :book, using: Api::Entities::Book do |request|
        request.book
    end
    expose :requested_at
    expose :is_approved
end