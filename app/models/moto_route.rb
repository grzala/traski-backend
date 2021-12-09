class MotoRoute < ApplicationRecord
    belongs_to :user
    has_many :point_of_interests, dependent: :destroy
    has_many :moto_route_favourites, dependent: :destroy
    has_many :moto_route_votes, dependent: :destroy
    has_many :comments, -> {order "created_at DESC"} , dependent: :destroy



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

    def recalculate_score
      votes = MotoRouteVote.where(moto_route: self)

      max_score = ((votes.count) * MotoRouteVote::MAX_VOTE_SCORE).to_f

      if max_score <= 0.0 # prevent division by 0 in later parts of the code
        self.score = 0.0
        self.save
        return
      end

      total_score = 0.0
      votes.each do |vote|
        total_score += vote.score.to_f
      end

      puts "VOTES COUNT"
      puts votes.count

      puts "TOTAL SCORE"
      puts total_score

      average = total_score / max_score

      puts "average"
      puts average

      self.score = average * MotoRouteVote::MAX_VOTE_SCORE.to_f
      self.save

    end

    def score_rounded
      '%.2f' % self.score
    end

  def serializable_hash(options={})
    to_return = super.merge ({
        :coordinates => self.coordinates,
        :score => self.score
    })
    
    if options[:with_user]
      users_vote = MotoRouteVote.find_by(user: options[:with_user], moto_route: self)
      users_vote = users_vote.score if users_vote != nil
      to_return.merge! ({
          :is_favourite => self.is_favourite?(options[:with_user]),
          :your_vote => users_vote
      })
    end

    return to_return
  end
end
