class Api::Entities::Fine < Grape::Entity
    expose :id, if: {type: :full}
    expose :member, using: Api::Entities::Member do |fine|
        fine.member
    end
    expose :borrow, using: Api::Entities::Borrow do |fine|
        fine.borrow
    end
    expose :fine_amount
    expose :paid_status
    expose :paid_at
    expose :fine_type
end