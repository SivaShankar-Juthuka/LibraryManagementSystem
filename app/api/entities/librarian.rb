class Api::Entities::Librarian < Grape::Entity
    expose :id,  if: {type: :full}
    expose :user, using: Api::Entities::User do |librarian|
        librarian.user
    end
    expose :library, using: Api::Entities::Library do |details|
        details.library
    end
end
