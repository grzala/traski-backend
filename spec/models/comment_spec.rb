require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @moto_route = FactoryBot.create(:useless_moto_route, user: @user)
    @comment = Comment.create(user: @user, moto_route: @moto_route, message: "Sample message")
  end

  describe "Creation" do
    it "Can be created" do
      expect(@comment).to be_truthy
      expect(@comment).to be_valid
    end

    it "Must have an associated user" do
      @comment.user = nil

      expect(@comment).not_to be_valid
    end

    it "Must have an associated moto route" do
      @comment.moto_route = nil

      expect(@comment).not_to be_valid
    end

    it "Must have a message" do 
      @comment.message = ""
      expect(@comment).not_to be_valid

      @comment.message = nil
      expect(@comment).not_to be_valid
    end

    it "Must have a message shorter than 400 characters" do 
      @comment.message = "a" * 400
      expect(@comment).not_to be_valid
    end

  end

  describe "Deletion" do 
    it "Is deleted if associated user is deleted" do
      @user.destroy

      expect { @comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "Is deleted if associated moto route is deleted" do
      @moto_route.destroy
      
      expect { @comment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
