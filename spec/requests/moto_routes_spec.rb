require 'rails_helper'

RSpec.describe "MotoRoutes", type: :request do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @moto_route1 = FactoryBot.create(:useless_moto_route, user: @user1)
    @moto_route2 = FactoryBot.create(:useless_moto_route, user: @user1)

    MotoRouteFavourite.create(moto_route: @moto_route1, user: @user1)

    login_as(@user1, :scope => :user)
  end


  describe "Favourite actions" do
    it "Can check if route is favourited by user" do
      get is_route_favourite_path(@moto_route1)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["is_favourite"]).to eq(true)
      
      get is_route_favourite_path(@moto_route2)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["is_favourite"]).to eq(false)
    end

    it "Can favourite route and unfavourite" do
      post switch_route_favourite_path, params: {id: @moto_route1.id}
      post switch_route_favourite_path, params: {id: @moto_route2.id}

      get is_route_favourite_path(@moto_route1)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["is_favourite"]).to eq(false)

      get is_route_favourite_path(@moto_route2)
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["is_favourite"]).to eq(true)
    end

    it "Does not allow favouriting actions if not signed in" do
      logout(:user)

      get is_route_favourite_path(@moto_route1)
      expect(response).to have_http_status(401)
      
      post switch_route_favourite_path, params: {id: @moto_route1.id}
      expect(response).to have_http_status(401)
    end

    it "Does not allow favouriting actions on unexisting routes" do
      logout(:user)

      get is_route_favourite_path(-1)
      expect(response).to have_http_status(401)
      
      post switch_route_favourite_path, params: {id: -1}
      expect(response).to have_http_status(401)
    end
  end


  describe "Voting actions" do
    before do
      @current_vote_attrs = {
        current_total: 0.0,
        vote_count: 0.0
      }
    end

    it "Allows users to vote and edit their vote" do
      post route_vote_path, params: {id: @moto_route1.id, score: 1}
      @moto_route1.reload
      @current_vote_attrs[:current_total] += 1.0
      @current_vote_attrs[:vote_count] += 1.0
      expect(response).to have_http_status(:success)
      expect(@moto_route1.score).to eq(@current_vote_attrs[:current_total] / @current_vote_attrs[:vote_count])

      post route_vote_path, params: {id: @moto_route2.id, score: 4}
      @moto_route2.reload
      expect(response).to have_http_status(:success)
      expect(@moto_route2.score).to eq(4.0)


      logout(:user)
      login_as(@user2, :scope => :user)

      post route_vote_path, params: {id: @moto_route1.id, score: 2}
      @moto_route1.reload
      @current_vote_attrs[:current_total] += 2.0
      @current_vote_attrs[:vote_count] += 1.0
      expect(response).to have_http_status(:success)
      expect(@moto_route1.score).to eq(@current_vote_attrs[:current_total] / @current_vote_attrs[:vote_count])

      post route_vote_path, params: {id: @moto_route1.id, score: 4}
      @moto_route1.reload
      @current_vote_attrs[:current_total] += 2.0
      expect(response).to have_http_status(:success)
      expect(@moto_route1.score).to eq(@current_vote_attrs[:current_total] / @current_vote_attrs[:vote_count])

    end

    # it "Doesn't allow users to vote invalid score numbers" do

    # end

    # it "Allows users to change vote" do
      
    # end

    # it "Allows users to get their already voted score" do
    #   get_user_route_vote
    # end

    # it "Does not allow not logged in users to perform any voting actions"
  end
end
