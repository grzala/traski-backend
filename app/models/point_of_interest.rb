class PointOfInterest < ApplicationRecord
    belongs_to :moto_route

    validates_presence_of :name, :description, :latitude, :longitude, :variant, :moto_route

    enum variant: { 
        FOOD: 0, 
        VISTA: 1, 
        URBEX: 2,
        DANGER: 3,
        FUEL: 4,
        OTHER: 5,
    }


    def coordinates
        {lat: self.latitude, lng: self.longitude}
    end

    def coordinates=(coordinates)
        self.latitude = coordinates[:lat]
        self.longitude = coordinates[:lng]
    end

    def serializable_hash(options={})
      super.merge ({
        
          :coordinates => self.coordinates
        
      })
    end



end
