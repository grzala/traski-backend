require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  describe "Creation" do

    it "Can be created" do
        expect(@user).to be_truthy
        expect(@user).to be_valid
    end

    it "Must have first name no longer than 15 characters" do
        @user.first_name = nil
        expect(@user).not_to be_valid

        @user.first_name = ""
        expect(@user).not_to be_valid

        @user.first_name = "a" * 16
        expect(@user).not_to be_valid
    end

    it "Must have last name no longer than 15 characters" do
        @user.last_name = nil
        expect(@user).not_to be_valid

        @user.last_name = ""
        expect(@user).not_to be_valid

        @user.last_name = "a" * 16
        expect(@user).not_to be_valid
    end

    it "Auto capitalizes name" do
        new_first_name = "hernando"
        new_last_name = "murray"

        @user.first_name = new_first_name
        @user.last_name = new_last_name
        @user.save

        expect(@user.first_name).to eq(new_first_name.capitalize)
        expect(@user.last_name).to eq(new_last_name.capitalize)
    end

  end

  describe "Actions" do
      it "Can return full name" do
          expect(@user.full_name).to eq(@user.first_name + " " + @user.last_name)
      end
      
      it "Can get next id" do
          expect(User.next_id).to eq(User.last.nil? ? 1 : User.last.id + 1)
      end

      it "Can return total routes added" do
        expect(@user.total_routes_added).to eq(0)
        moto_route = FactoryBot.create(:useless_moto_route, user: @user)
        expect(@user.total_routes_added).to eq(1)
        moto_route = FactoryBot.create(:useless_moto_route, user: @user)
        expect(@user.total_routes_added).to eq(2)
      end

      it "Returns virtual fields as part of json serialized object" do
        serialized = @user.serializable_hash(include_virtual: [:total_routes_added])
        expect(serialized[:full_name]).to eq(@user.full_name)
        expect(serialized[:total_routes_added]).to eq(@user.total_routes_added)
      end
  end

end