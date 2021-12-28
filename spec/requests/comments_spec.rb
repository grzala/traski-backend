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

    login_as(@user1, :scope => :user)
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
    it "Allows creating comments" do
      @new_comment_data = {
        moto_route_id: @moto_route1.id,
        message: "new message"
      }
      post create_comment_path(@moto_route1.id), params: @new_comment_data

      expect(response).to have_http_status(:success)
      expect(Comment.last.message).to eq(@new_comment_data[:message])
    end

    it "Does not allow to create comments if not logged in" do
      @new_comment_data = {
        moto_route_id: @moto_route1.id,
        message: "new message"
      }
      logout(:user)
      post create_comment_path(@moto_route1.id), params: @new_comment_data

      expect(response).to have_http_status(401)
      expect(Comment.last.message).not_to eq(@new_comment_data[:message])
    end
    
    it "Returns error if commenting on non-existant route" do
      post create_comment_path(-1)
      expect(response).to have_http_status(401)
    end
  end

  describe "Delete comment" do
    it "Allows to delete comments" do
      delete comment_path(@comment1)
      
      expect(response).to have_http_status(:success)
      expect { @comment1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "Does not allow deleting someone else's comments" do
      delete comment_path(@comment3)
      
      expect(response).to have_http_status(401)

      @comment3.reload
      expect(@comment3).not_to be_nil
    end

    it "Does not allow deleting comments if not logged in" do
      sign_out @user1
      delete comment_path(@comment1)
      
      expect(response).to have_http_status(401)
      @comment1.reload
      expect(@comment1).not_to be_nil
    end

  end
end
