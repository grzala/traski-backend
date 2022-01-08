class PointOfInterest < ApplicationRecord
    belongs_to :moto_route

    validates_presence_of :name, :description, :latitude, :longitude, :variant, :moto_route
    validates :latitude, numericality: { greater_than: -90, less_than: 90 }
    validates :longitude, numericality: { greater_than: -180, less_than_or_equal_to: 180 }

    MIN_NAME_LENGTH = 5
    MAX_NAME_LENGTH = 20
    MIN_DESCRIPTION_LENGTH = 20
    MAX_DESCRIPTION_LEGTH = 50


    validates_length_of :name, minimum: MIN_NAME_LENGTH, allow_blank: false, message: "Name must be minumum #{MIN_NAME_LENGTH} characters long"
    validates_length_of :name, maximum: MAX_NAME_LENGTH, allow_blank: false, message: "Name cannot exceed #{MAX_NAME_LENGTH} characters"
    validates_length_of :description, minimum: MIN_DESCRIPTION_LENGTH, allow_blank: false, message: "Description must be minumum #{MIN_DESCRIPTION_LENGTH} characters long"
    validates_length_of :description, maximum: MAX_DESCRIPTION_LEGTH, allow_blank: false, message: "Description cannot exceed #{MAX_DESCRIPTION_LEGTH} characters"

    MAX_VARIANT = 5
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
