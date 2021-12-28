require 'rails_helper'

RSpec.describe "Comments", type: :request do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @moto_route1 = FactoryBot.create(:useless_moto_route, user: @user1)
    @moto_route2 = FactoryBot.create(:useless_moto_route, user: @user2)
    
    @comment1 = Comment.create(user: @user1, moto_route: @moto_route1, message: "Sample message1")
    @comment2 = Comment.create(user: @user1, moto_route: @moto_route1, message: "Sample message2")
    @comment3 = Comment.create(user: @user2, moto_route: @moto_route1, message: "Sample message3")
    
    @comment4 = Comment.create(user: @user1, moto_route: @moto_route2, message: "Sample message4")
    @comment5 = Comment.create(user: @user1, moto_route: @moto_route2, message: "Sample message5")
    @comment6 = Comment.create(user: @user2, moto_route: @moto_route2, message: "Sample message6")

    sign_in @user1
  end


  describe "Get comments for route" do
    it "Can get all comments for given route" do
      get get_comments_for_route_path(@moto_route1)
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment1.to_json))
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment2.to_json))
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment3.to_json))
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment4.to_json))
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment5.to_json))
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment6.to_json))

      logout(:user)
      get get_comments_for_route_path(@moto_route2)
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment1.to_json))
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment2.to_json))
      expect(JSON.parse(response.body)).not_to include(JSON.parse(@comment3.to_json))
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment4.to_json))
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment5.to_json))
      expect(JSON.parse(response.body)).to include(JSON.parse(@comment6.to_json))
    end

    it "Returns error if non existant route requested" do
      get get_comments_for_route_path(10000)
      expect(response).to have_http_status(404)
    end
  end

  describe "Create comment for route" do
    it "Does not allow to create comments if not logged in" do
    end
    
    it "Returns error if commenting on non-existant route" do
      get get_comments_for_route_path(10000)
      expect(response).to have_http_status(404)
    end
  end
end
