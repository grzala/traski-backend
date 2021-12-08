# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



# unless ENV["var"]


require_relative 'seeds/users.rb'
require_relative 'seeds/motoroutes.rb'

added_users = []
UserSeed::USERS.each do |user|
    added_users << User.create!(user)
end

MotoRoutesSeed::MOTO_ROUTES.each do |moto_route|
    MotoRoute.create!(moto_route.merge({user: added_users[0]}))
end