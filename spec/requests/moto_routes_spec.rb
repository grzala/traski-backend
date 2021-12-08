require 'rails_helper'

RSpec.describe "MotoRoutes", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/moto_routes/show"
      expect(response).to have_http_status(:success)
    end
  end

end
