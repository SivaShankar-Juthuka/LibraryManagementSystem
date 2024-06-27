# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(email: 'admin001@ndl.com', password: '123456789', password_confirmation: '123456789')
User.create!(email: 'admin002@ndl.com', password: '123456789', password_confirmation: '123456789')

# created users id should be set that id in admin table
Admin.create!(user_id: 1)
Admin.create!(user_id: 2)

# create a library
Library.create!(library_name: 'National Digital Library', library_address: 'Delhi, India')
Library.create!(library_name: 'Central Library', library_address: 'Hyderabad, India')
Library.create!(library_name: 'British Council Library', library_address: 'Mumbai, India')

