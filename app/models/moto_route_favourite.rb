class MotoRouteFavourite < ApplicationRecord
    belongs_to :user
    belongs_to :moto_route
end
