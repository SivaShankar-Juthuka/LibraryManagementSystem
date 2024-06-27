# app/model/current.rb
class Current < ActiveSupport::CurrentAttributes
    attribute :user
    attribute :library_id
end