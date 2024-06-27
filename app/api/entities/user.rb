class Api::Entities::User < Grape::Entity
    expose :id,  if: { type: :private}
    expose :user_name
    expose :email
    expose :is_assigned, if: {type: :private}
end