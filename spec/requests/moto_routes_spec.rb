require 'rails_helper'

RSpec.describe "MotoRoutes", type: :request do
  before do
    @user1 = FactoryBot.create(:user)
    @moto_route1 = FactoryBot.create(:useless_moto_route, user: @user1)
    @moto_route2 = FactoryBot.create(:useless_moto_route, user: @user1)

    MotoRouteFavourite.create(moto_route: @moto_route1, user: @user1)

    login_as(@user1, :scope => :user)
  end


  describe "Favourite actions" do
    it "Can check if route is favourited by user" do
      get is_route_favourite_path(@moto_route1)
      expect(response).to have_http_status(:success)
      puts JSON.parse(response.body)
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
  end
end
