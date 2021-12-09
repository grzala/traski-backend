class MotoRoute < ApplicationRecord
    belongs_to :user
    has_many :point_of_interests, dependent: :destroy
    has_many :moto_route_favourites, dependent: :destroy

    validates_presence_of :user, :name, :description, :coordinates_json_string,
                            :time_to_complete_h, :time_to_complete_m, :difficulty

    accepts_nested_attributes_for :point_of_interests

    def coordinates
        return JSON.parse self.coordinates_json_string
    end

    def coordinates=(coords_obj)
        self.coordinates_json_string = coords_obj.to_json
    end

    def is_favourite?(user)
      # ternary operator needs to be here, otherwise nil was returned instead of false
      return user && MotoRouteFavourite.find_by(user: user, moto_route: self) ? true : false
    end


  def serializable_hash(options={})
    to_return = super.merge ({
        :coordinates => self.coordinates,
    })
    
    if options[:with_user]
      to_return.merge! ({
          :is_favourite => self.is_favourite?(options[:with_user])
      })
    end

    return to_return
  end
end
