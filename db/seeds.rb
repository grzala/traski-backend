# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



# unless ENV["var"]

require_relative 'seeds/motoroutes.rb'

# USERS

USER_COUNT = 40
USER_AVATAR_FOLDER_PATH = "./public/avatars"
USER_SEED_AVATAR_PATH = "./db/seeds/avatars"
USER_PLACEHOLDER_AVATAR_PATH = "./db/seeds/avatars/placeholder.png"

added_users = []

# Remove all avatars
FileUtils.rm_rf Dir["#{USER_AVATAR_FOLDER_PATH}/*"] if USER_AVATAR_FOLDER_PATH.present?

# Provide placeholder avatar
FileUtils.cp(USER_PLACEHOLDER_AVATAR_PATH, USER_AVATAR_FOLDER_PATH)

# Create users with avatars
(0...USER_COUNT).each do |i|
    user = FactoryBot.create(:user)
    added_users << user
    FileUtils.cp("#{USER_SEED_AVATAR_PATH}/#{user.id}.png", "#{USER_AVATAR_FOLDER_PATH}/#{user.id}.png")
end


# ROUTES

ROUTE_THUMBNAIL_SEED_PATH = "./db/seeds/route_thumbnails"
ROUTE_THUMBNAIL_FOLDER_PATH = "./public/route_thumbnails"
MotoRoutesSeed::MOTO_ROUTES.each_with_index do |moto_route, i|
    #route = MotoRoute.create!(moto_route.merge({user: added_users[i % added_users.length]}))
    #FileUtils.cp("#{ROUTE_THUMBNAIL_SEED_PATH}/#{i}.png", "#{ROUTE_THUMBNAIL_FOLDER_PATH}/#{route.id}.png")
end