class MotoRoute < ApplicationRecord
    belongs_to :user
    has_many :point_of_interests, dependent: :destroy

    validates_presence_of :user, :name, :description, :coordinates_json_string,
                            :time_to_complete_h, :time_to_complete_m, :difficulty

    accepts_nested_attributes_for :point_of_interests

    def coordinates
        return JSON.parse self.coordinates_json_string
    end

    def coordinates=(coords_obj)
        self.coordinates_json_string = coords_obj.to_json
    end
end
