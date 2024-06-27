class Api::Entities::Member < Grape::Entity
    expose :id,  if: { type: [:full, :private] }
    expose :user, using: Api::Entities::User do |member, options|
        member.user
    end
    expose :library, using: Api::Entities::Library do |member, options|
        member.library
    end
    expose:borrowing_limit, if: {type: :private}
end
