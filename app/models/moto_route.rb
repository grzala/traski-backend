class MotoRoute < ApplicationRecord
    belongs_to :user
    has_many :point_of_interests, dependent: :destroy
    has_many :moto_route_favourites, dependent: :destroy
    has_many :moto_route_votes, dependent: :destroy
    has_many :comments, -> {order "created_at DESC"} , dependent: :destroy


    validates_presence_of :user, :name, :description, :coordinates_json_string,
                            :time_to_complete_h, :time_to_complete_m, :difficulty

    validates :difficulty, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
    validates :time_to_complete_h, numericality: { greater_than_or_equal_to: 0, less_than: 24 }
    validates :time_to_complete_m, numericality: { greater_than_or_equal_to: 0, less_than: 60 }

    accepts_nested_attributes_for :point_of_interests


    MIN_NAME_LENGTH = 5
    MAX_NAME_LENGTH = 50
    MIN_DESCRIPTION_LENGTH = 20
    MAX_DESCRIPTION_LEGTH = 400

    validates_length_of :name, minimum: MIN_NAME_LENGTH, allow_blank: false, message: "Name must be minumum #{MIN_NAME_LENGTH} characters long"
    validates_length_of :name, maximum: MAX_NAME_LENGTH, message: "Name cannot exceed #{MAX_NAME_LENGTH} characters"
    validates_length_of :description, minimum: MIN_DESCRIPTION_LENGTH, allow_blank: false, message: "Description must be minumum #{MIN_DESCRIPTION_LENGTH} characters long"
    validates_length_of :description, maximum: MAX_DESCRIPTION_LEGTH, message: "Description cannot exceed #{MAX_DESCRIPTION_LEGTH} characters"


    validate :check_coordinate_duplicates
    validate :check_at_least_two_coordinates
    validate :lat_and_lng



    def coordinates
        return JSON.parse self.coordinates_json_string
    end

    def coordinates=(coords_obj)
        self.coordinates_json_string = coords_obj.to_json
    end

    def is_favourite?(user)
      # Ternary operator needs to be here, otherwise nil was returned instead of false
      return user && MotoRouteFavourite.find_by(user: user, moto_route: self) ? true : false
    end

    def recalculate_score
      votes = MotoRouteVote.where(moto_route: self)

      max_score = ((votes.count) * MotoRouteVote::MAX_VOTE_SCORE).to_f

      if max_score <= 0.0 # Prevent division by 0 in later parts of the code
        self.score = 0.0
        self.save
        return
      end

      total_score = 0.0
      votes.each do |vote|
        total_score += vote.score.to_f
      end

      average = total_score / max_score
      

      self.score = average * MotoRouteVote::MAX_VOTE_SCORE.to_f
      self.save
    end

  def score_rounded
    '%.2f' % self.score
  end

  def get_poi_count
    poi_count = {}
    self.point_of_interests.each do |poi|
      if !poi_count.has_key? poi.variant
        poi_count[poi.variant] = 0
      end

      poi_count[poi.variant] += 1
    end

    return poi_count
  end


  def serializable_hash(options={})
    to_return = super.merge ({
        :coordinates => self.coordinates,
        :score => self.score
    })
    
    if options[:with_user]
      # This needs to be handled in a separate request
      # users_vote = MotoRouteVote.find_by(user: options[:with_user], moto_route: self)
      # users_vote = users_vote.score if users_vote != nil
      # to_return.merge! ({
      #     :is_favourite => self.is_favourite?(options[:with_user]),
      #     :your_vote => users_vote
      # })
    end


    if options[:with_poi_count]

      to_return.merge!({
        poi_count: self.get_poi_count
      })
    
    end

    return to_return
  end


  private
  # Allow setting json coordinates only privately to control what string is being saved into this attribute
  def coordinates_json_string=(new_coords)
    write_attribute(:coordinates_json_string, new_coords)
  end

  def check_coordinate_duplicates
    coordinates = self.coordinates
    coordinates.sort_by!{ |c| [c['lat'], c['lng']] }

    (0...coordinates.length-1).each do |i|
      if coordinates[i] == coordinates[i+1]
        self.errors.add(:coordinates, "Duplicate waypoints in route are not allowed")
      end
    end
  end


  def check_at_least_two_coordinates
    if self.coordinates.length < 2
      errors.add(:coordinates, "At least two waypoints required to make a route")
    end
  end

  def lat_and_lng
    self.coordinates.each do |coord|
      if (coord['lat'] >= 90 || coord['lat'] <= -90) || ((coord['lng'] > 180 || coord['lng'] <= -180))
        self.errors.add(:coordinates, "All waypoints must have valid coordinates")
        return
      end
    end
  end
end
