# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



# unless ENV["var"]

require_relative 'seeds/motoroutes.rb'
require_relative 'seeds/comments.rb'

# USERS

USER_COUNT = 40
USER_AVATAR_FOLDER_PATH = "./public/avatars"
USER_SEED_AVATAR_PATH = "./db/seeds/avatars"
USER_PLACEHOLDER_AVATAR_PATH = "./db/seeds/avatars/placeholder.png"

added_users = []

puts "seeding users..."

# Remove all avatars
FileUtils.rm_rf Dir["#{USER_AVATAR_FOLDER_PATH}/*"] if USER_AVATAR_FOLDER_PATH.present?

# Provide placeholder avatar
FileUtils.cp(USER_PLACEHOLDER_AVATAR_PATH, USER_AVATAR_FOLDER_PATH)

# Create users with avatars
# don't create routes as all of the users
(0...USER_COUNT).each do |i|
    user = FactoryBot.create(:user)
    added_users << user
    FileUtils.cp("#{USER_SEED_AVATAR_PATH}/#{user.id}.png", "#{USER_AVATAR_FOLDER_PATH}/#{user.id}.png")
end


# ROUTES
puts "seeding routes..."

ROUTE_THUMBNAIL_SEED_PATH = "./db/seeds/route_thumbnails"
ROUTE_THUMBNAIL_FOLDER_PATH = "./public/route_thumbnails"
MotoRoutesSeed::MOTO_ROUTES.each_with_index do |moto_route, i|
    moto_route.delete(:id)
    pois = moto_route.delete(:point_of_interests)
    author_id = rand(1..USER_COUNT/4)

    route = MotoRoute.create!(moto_route.merge({user_id: author_id}))
    FileUtils.cp("#{ROUTE_THUMBNAIL_SEED_PATH}/#{i}.png", "#{ROUTE_THUMBNAIL_FOLDER_PATH}/#{route.id}.png")

    pois.each do |poi|
        poi.delete(:id)

        PointOfInterest.create!(poi.merge({moto_route: route}))
    end
end


# COMMENTS, FAVS AND RATINGS
puts "seeding comments and ratings..."

FEEDBACK_TYPES = [:NEGATIVE, :INDIFFERENT, :POSITIVE]

RATING_PROBS = [0.15, 0.45, 1.0]

RATINGS = {
    NEGATIVE: [1, 2],
    INDIFFERENT: [2, 3],
    POSITIVE: [4, 5],
}


USER_LEAVE_COMMENT_PROB = 0.2
USER_LEAVE_RATING_PROB = 0.6
USER_ADD_TO_FAVS_PROB = 0.3

User.all.each do |user|
    MotoRoute.all.each do |route|
        type = :POSITIVE
        type_random_no = rand(0.0..1.0)
        if type_random_no <= RATING_PROBS[0]
            type = :NEGATIVE
        elsif type_random_no <= RATING_PROBS[1]
            type = :INDIFFERENT
        end

        if rand(0.0..1.0) <= USER_LEAVE_RATING_PROB
            rating = RATINGS[type].sample
            MotoRouteVote.create!(user: user, moto_route: route, score: rating)
        end

        if rand(0.0..1.0) <= USER_ADD_TO_FAVS_PROB
            MotoRouteFavourite.create!(user: user, moto_route: route)
        end

        if rand(0.0..1.0) <= USER_LEAVE_COMMENT_PROB
            CommentsSeed::COMMENTS[type].sample
            Comment.create!(user: user, moto_route: route, message: CommentsSeed::COMMENTS[type].sample)
        end
    end
end