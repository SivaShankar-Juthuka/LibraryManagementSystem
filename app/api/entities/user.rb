class Api::Entities::User < Grape::Entity
    expose :id,  if: { type: [:full, :private] }
    expose :user_name
    expose :email
    expose :is_assigned, if: {type: :private}
end
