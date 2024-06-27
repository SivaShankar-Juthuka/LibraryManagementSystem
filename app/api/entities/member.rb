class Api::Entities::Member < Grape::Entity
    expose :id,  if: {type: :full}
    expose :user, using: Api::Entities::User do |member, options|
        member.user
    end
    expose :library, using: Api::Entities::Library do |member, options|
        member.library
    end
    expose:borrowing_limit
end
