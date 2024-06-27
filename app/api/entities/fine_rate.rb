# app/api/entities/fine_rate.rb
class Api::Entities::FineRate < Grape::Entity
    expose :id, if: {type: :full}
    expose :library, using: Api::Entities::Library do |finerate|
        finerate.library
    end
    expose :fine_type
    expose :fine_amount
end
