class Api::Entities::Fine < Grape::Entity
    expose :id, if: {type: :full}
    expose :member, using: Api::Entities::Member do |fine, options|
        fine.member
    end
    expose :borrow, using: Api::Entities::Borrow do |fine, options|
        fine.borrow
    end
    expose :fine_amount
    expose :paid_status
    expose :paid_at
    expose :fine_type
end