class MotoRouteFavourite < ApplicationRecord
    belongs_to :user
    belongs_to :moto_route

    PER_PAGE_USER_FAVOURITES = 10
    scope :get_user_favourites, -> (user, offset) { where(user: user).order(created_at: :desc).limit(PER_PAGE_USER_FAVOURITES).offset(offset) }


end
