require 'rails_helper'

def mimic_vote(moto_route, user, score, current_vote_attrs)
    current_vote_attrs[:current_total] += score


    vote = MotoRouteVote.find_by(moto_route: moto_route, user: user)

    if vote
        current_vote_attrs[:current_total] -= vote.score
        vote.score = score
        vote.save
    else
        MotoRouteVote.create(moto_route: moto_route, user: user, score: score)
        current_vote_attrs[:vote_count] += 1.0
    end

    return current_vote_attrs
end

def mimic_poi_count(poi_count, poi)
    if !poi_count.has_key? poi.variant
        poi_count[poi.variant] = 0
    end

    poi_count[poi.variant] += 1
    return poi_count
end

RSpec.describe MotoRoute, type: :model do
    before do
        @user = FactoryBot.create(:user)
        @moto_route = FactoryBot.create(:useless_moto_route, user: @user)
    end

    describe "Creation" do
        it "Can be created" do
            expect(@moto_route).to be_valid
        end

        it "Validates difficulty to be between 1 and 10" do
            @moto_route.difficulty = 0
            expect(@moto_route).not_to be_valid
            @moto_route.difficulty = 1
            expect(@moto_route).to be_valid
            @moto_route.difficulty = 10
            expect(@moto_route).to be_valid
            @moto_route.difficulty = 11
            expect(@moto_route).not_to be_valid
        end

        # This was causing problems with seeding
        # it "Disallows direct assignment of json coordinates" do
        #     expect { @moto_route.coordinates_json_string = "test" }.to raise_error(NoMethodError)
        # end

        it "Validates name length to be between 5 and 50 characters" do
            @moto_route.name = ""
            expect(@moto_route).not_to be_valid
            @moto_route.name = "yyyy"
            expect(@moto_route).not_to be_valid
            @moto_route.name = "yyyyy"
            expect(@moto_route).to be_valid


            @moto_route.name = "y" * 51
            expect(@moto_route).not_to be_valid
            @moto_route.name = "y" * 50
            expect(@moto_route).to be_valid
        end

        it "Validates description length to be between 20 and 400 characters" do
            @moto_route.description = ""
            expect(@moto_route).not_to be_valid
            @moto_route.description = "yyyy"
            expect(@moto_route).not_to be_valid
            @moto_route.description = "y" * 20
            expect(@moto_route).to be_valid


            @moto_route.description = "y" * 401
            expect(@moto_route).not_to be_valid
            @moto_route.description = "y" * 400
            expect(@moto_route).to be_valid
        end

        it "Expects json coordinates not to have duplicate waypoints" do
            @moto_route.coordinates = [{lat: 20, lng: 20}, {lat: 20, lng: 20}]
            expect(@moto_route).not_to be_valid
            @moto_route.coordinates = [{lat: 20, lng: 31}, {lat: 10, lng: 12}, {lat: 20, lng: 25}, {lat: 20, lng: 31}, {lat: 21, lng: 22}]
            expect(@moto_route).not_to be_valid
        end

        it "Expects json coordinates array to have at least two waypoints" do
            @moto_route.coordinates = []
            expect(@moto_route).not_to be_valid
            @moto_route.coordinates = [{lat: 20, lng: 20}]
            expect(@moto_route).not_to be_valid
            @moto_route.coordinates = [{lat: 20, lng: 20}, {lat: 30, lng: 30}]
            expect(@moto_route).to be_valid
        end


        it "Expects json coordinates to have valid latitude and longitude" do
            coords = [{lat: 0, lng: 0}, {lat: 1, lng: 1}]
            @moto_route.coordinates = coords
            expect(@moto_route).to be_valid


            coords = [{lat: -89.9, lng: -179.9}, {lat: 89.9, lng: 180.0}]
            @moto_route.coordinates = coords
            expect(@moto_route).to be_valid
    
            coords = [{lat: -90, lng: 0}, {lat: 0, lng: 0}]
            @moto_route.coordinates = coords
            expect(@moto_route).not_to be_valid

            coords = [{lat: 90, lng: 0}, {lat: 0, lng: 0}]
            @moto_route.coordinates = coords
            expect(@moto_route).not_to be_valid

            coords = [{lat: 0, lng: -180}, {lat: 0, lng: 0}]
            @moto_route.coordinates = coords
            expect(@moto_route).not_to be_valid

            coords = [{lat: 0, lng: 180.1}, {lat: 0, lng: 0}]
            @moto_route.coordinates = coords
            expect(@moto_route).not_to be_valid
        end

        it "Expects hours to complete to be between 0 and 23" do
            @moto_route.time_to_complete_h = -1
            expect(@moto_route).not_to be_valid
            @moto_route.time_to_complete_h = 0
            expect(@moto_route).to be_valid
            @moto_route.time_to_complete_h = 23
            expect(@moto_route).to be_valid
            @moto_route.time_to_complete_h = 24
            expect(@moto_route).not_to be_valid
        end

        it "Expects minutes to complete to be between 0 and 60" do
            @moto_route.time_to_complete_m = -1
            expect(@moto_route).not_to be_valid
            @moto_route.time_to_complete_m = 0
            expect(@moto_route).to be_valid
            @moto_route.time_to_complete_m = 59
            expect(@moto_route).to be_valid
            @moto_route.time_to_complete_m = 60
            expect(@moto_route).not_to be_valid
        end

        it "Expects valid open and close dates" do
            @moto_route.date_open_day = 0
            expect(@moto_route).not_to be_valid
            @moto_route.date_open_day = 32
            expect(@moto_route).not_to be_valid
            @moto_route.date_open_day = 15
            expect(@moto_route).to be_valid

            @moto_route.date_open_month = 0
            expect(@moto_route).not_to be_valid
            @moto_route.date_open_month = 13
            expect(@moto_route).not_to be_valid
            @moto_route.date_open_month = 12
            expect(@moto_route).to be_valid

            @moto_route.date_closed_day = 0
            expect(@moto_route).not_to be_valid
            @moto_route.date_closed_day = 32
            expect(@moto_route).not_to be_valid
            @moto_route.date_closed_day = 15
            expect(@moto_route).to be_valid

            @moto_route.date_closed_month = 0
            expect(@moto_route).not_to be_valid
            @moto_route.date_closed_month = 13
            expect(@moto_route).not_to be_valid
            @moto_route.date_closed_month = 12
            expect(@moto_route).to be_valid
        end
    end

    describe "Deletion" do 
        it "Is destroyed along with associated user" do
            @user.destroy
            expect { @moto_route.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
    end

    describe "Actions" do
        it "Can return if favourited by user" do 
            user2 = FactoryBot.create(:user)

            expect(@moto_route.is_favourite?(@user)).to eq(false)
            expect(@moto_route.is_favourite?(user2)).to eq(false)

            MotoRouteFavourite.create(moto_route: @moto_route, user: @user)
            expect(@moto_route.is_favourite?(@user)).to eq(true)
            expect(@moto_route.is_favourite?(user2)).to eq(false)
            
            MotoRouteFavourite.find_by(moto_route: @moto_route, user: @user).delete
            MotoRouteFavourite.create(moto_route: @moto_route, user: user2)
            expect(@moto_route.is_favourite?(@user)).to eq(false)
            expect(@moto_route.is_favourite?(user2)).to eq(true)


            expect(@moto_route.is_favourite?(nil)).to eq(false)
        end

        it "Can set and get coordinates with hashes" do
            new_coords = [
                {lat: 20.0, lng: 30.0},
                {lat: 21.0, lng: 31.0},
                {lat: 22.0, lng: 32.0},
                {lat: 23.0, lng: 33.0},
                {lat: 24.0, lng: 34.0},
            ]

            @moto_route.coordinates = new_coords
            # To json, as ruby makes it difficult to compare between hashes with symbols as keys and strings as keys
            expect(@moto_route.coordinates.to_json).to eq(new_coords.to_json) 
            expect(@moto_route.coordinates_json_string).to eq(new_coords.to_json)
        end

        it "Can return poi count" do
            poi_count = {}

            expect(@moto_route.get_poi_count).to eq(poi_count)

            poi = FactoryBot.create(:random_poi, moto_route: @moto_route)
            @moto_route.reload
            mimic_poi_count(poi_count, poi)
            expect(@moto_route.get_poi_count).to eq(poi_count)

            poi = FactoryBot.create(:random_poi, moto_route: @moto_route)
            @moto_route.reload
            mimic_poi_count(poi_count, poi)
            expect(@moto_route.get_poi_count).to eq(poi_count)

            poi = FactoryBot.create(:random_poi, moto_route: @moto_route)
            @moto_route.reload
            mimic_poi_count(poi_count, poi)
            expect(@moto_route.get_poi_count).to eq(poi_count)

            poi_count[poi.variant] -= 1
            poi_count.delete(poi.variant) if poi_count[poi.variant] <= 0
            poi.destroy
            @moto_route.reload
            expect(@moto_route.get_poi_count).to eq(poi_count)
        end

        it "Can return auto-updated average score" do
            user1 = FactoryBot.create(:user)
            user2 = FactoryBot.create(:user)
            user3 = FactoryBot.create(:user)
            user4 = FactoryBot.create(:user)

            current_vote_attrs = {
                current_total: 0.0,
                vote_count: 0.0
            }

            expect(@moto_route.score).to eq(0.0)

            current_vote_attrs = mimic_vote(@moto_route, user1, 1, current_vote_attrs)
            expect(@moto_route.score).to eq(current_vote_attrs[:current_total] / current_vote_attrs[:vote_count])

            current_vote_attrs = mimic_vote(@moto_route, user1, 2, current_vote_attrs)
            @moto_route.reload
            expect(@moto_route.score).to eq(current_vote_attrs[:current_total] / current_vote_attrs[:vote_count])


            current_vote_attrs = mimic_vote(@moto_route, user2, 4, current_vote_attrs)
            current_vote_attrs = mimic_vote(@moto_route, user3, 5, current_vote_attrs)
            expect(@moto_route.score).to eq(current_vote_attrs[:current_total] / current_vote_attrs[:vote_count])

            current_vote_attrs = mimic_vote(@moto_route, user4, 4, current_vote_attrs)
            expect(@moto_route.score).to eq(current_vote_attrs[:current_total] / current_vote_attrs[:vote_count])

            user4.destroy
            current_vote_attrs[:current_total] -= 4.0
            current_vote_attrs[:vote_count] -= 1.0
            @moto_route.reload
            expect(@moto_route.score).to eq(current_vote_attrs[:current_total] / current_vote_attrs[:vote_count])

        end
    end
end

