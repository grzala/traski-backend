class MotoRoutesController < ApplicationController
  def index
    render json: {
      moto_routes: MotoRoute.all
    }, :include => [:point_of_interests]
  end
end
