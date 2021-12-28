class MotoRouteVote < ApplicationRecord
    belongs_to :user
    belongs_to :moto_route

    validates_uniqueness_of :moto_route, scope: :user

    MAX_VOTE_SCORE = 5


    after_save :force_moto_route_recalculate_score
    after_destroy :force_moto_route_recalculate_score


    private 
    def force_moto_route_recalculate_score
        self.moto_route.recalculate_score
    end

end
