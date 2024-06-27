class Api::Entities::Library < Grape::Entity
    expose :id, if: {type: :full}
    expose :library_name
    expose :library_address
end