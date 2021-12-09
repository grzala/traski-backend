class MotoRoutesController < ApplicationController
  before_action :set_motoRoute, only: [:show]

  def index
    render json: {
      moto_routes: MotoRoute.all
    }, :include => [:point_of_interests]
  end

  def show
    if (!@motoRoute) 
      return render json: {
        messages: ["Moto route with id: #{params[:id]} not found"]
      }, :status => 404
    end

    render json: {
      moto_route: @motoRoute
    }, :include => [:point_of_interests],
       :with_user => current_user
  end

  private 
  
  def set_motoRoute
      @motoRoute = MotoRoute.find(params[:id])
  end
end
