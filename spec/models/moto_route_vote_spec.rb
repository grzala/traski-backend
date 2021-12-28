require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @moto_route = FactoryBot.create(:useless_moto_route, user: @user)
    @vote = MotoRouteVote.create(user: @user, moto_route: @moto_route, score: 2)
  end

  describe "Creation" do
    it "Validates score vote to be between 1 and 5" do
        expect(@vote).to be_valid

        @vote.score = 0
        expect(@vote).not_to be_valid

        @vote.score = 6
        expect(@vote).not_to be_valid
    end
  end
end