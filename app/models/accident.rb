class Accident < ApplicationRecord
    validates_presence_of :latitude, :longitude, :date, :original_id, :injury

    validates :latitude, numericality: { greater_than: -90, less_than: 90 }
    validates :longitude, numericality: { greater_than: -180, less_than_or_equal_to: 180 }
    validates_uniqueness_of :original_id # There is never a reason to have the same accident scraped twice


    enum injury: { 
        NONE: 0, 
        LIGHT: 1, 
        HEAVY: 2,
        DEATH: 3,
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
