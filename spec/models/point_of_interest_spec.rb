require 'rails_helper'

RSpec.describe PointOfInterest, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @moto_route = FactoryBot.create(:useless_moto_route, user: @user)
    @poi = FactoryBot.create(:random_poi, moto_route: @moto_route)
  end

  describe "Creation" do
    it "Can be created" do
      expect(@poi).to be_truthy
      expect(@poi).to be_valid
    end

    it "Must have an associated moto route" do
      @poi.moto_route = nil

      expect(@poi).not_to be_valid
    end

    it "Must have valid latitude" do
      @poi.latitude = 0
      expect(@poi).to be_valid

      @poi.latitude = -89.9
      expect(@poi).to be_valid

      @poi.latitude = 89.9
      expect(@poi).to be_valid

      @poi.latitude = -90
      expect(@poi).not_to be_valid

      @poi.latitude = 90
      expect(@poi).not_to be_valid
    end

    it "Must have valid longitude" do
      @poi.longitude = 0
      expect(@poi).to be_valid

      @poi.longitude = -179.9
      expect(@poi).to be_valid

      @poi.longitude = 180.0
      expect(@poi).to be_valid

      @poi.longitude = -180.0
      expect(@poi).not_to be_valid

      @poi.longitude = 180.1
      expect(@poi).not_to be_valid
    end

  end

  describe "Deletion" do
    it "Is deleted if associated moto route is deleted" do
      @moto_route.destroy
      
      expect { @poi.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "Is deleted if author of associated moto route is deleted" do
      @user.destroy

      expect { @poi.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  describe "Actions" do
    it "Can return coordinates as hash" do
      lat = @poi.latitude
      lng = @poi.longitude
      expect(@poi.coordinates).to eq({lat: lat, lng: lng})
    end

    it "Can accept coordinates as hash" do
      new_lat = 20
      new_lng = 80
      @poi.coordinates = {lat: new_lat, lng: new_lng}

      expect(@poi.latitude).to eq(new_lat)
      expect(@poi.longitude).to eq(new_lng)
    end

    it "Returns coordinates as part of json serialized object" do
      serialized = @poi.serializable_hash
      expect(serialized[:coordinates]).to eq({lat: @poi.latitude, lng: @poi.longitude})
    end

  end
end
