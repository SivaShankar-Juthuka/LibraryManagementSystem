class Api::Entities::Login < Grape::Entity
    expose :token
    expose :user, using: Api::Entities::User do 
        expose :user_name
        expose :email
    end
end