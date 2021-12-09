class MotoRoutesController < ApplicationController
  before_action :set_moto_route, only: [:show, :switch_favourite]

  def index
    render json: {
      moto_routes: MotoRoute.all
    }, :include => [:point_of_interests]
  end

  def show
    if (!@moto_route) 
      return render json: {
        messages: ["Moto route with id: #{params[:id]} not found"]
      }, :status => 404
    end

    render json: {
      moto_route: @moto_route
    }, :include => [:point_of_interests],
       :with_user => current_user
  end

  def switch_favourite
    err = false
    msgs = []

    if !current_user
      err = true
      msgs << "You must be logged in to perform this action"
    end

    puts "yooooo"
    puts @moto_route
    puts
    if !@moto_route
      err = true
      msgs << "Route of id: #{params[:id]} does not exist"
    end

    if err
      return render json: {
        messages: msgs
      }, :status => 401
    end

    fav = MotoRouteFavourite.find_by(user: current_user, moto_route: @moto_route)
    fav_status = false

    if fav
      fav.destroy
      fav_status = false
    else
      fav = MotoRouteFavourite.create(user: current_user, moto_route: @moto_route)
      fav_status = true
    end

    msg = "#{@moto_route.name} #{fav_status ? "added to" : "removed from"} favourites"

    return render json: {
      messages: [msg],
      fav_status: fav_status
    }

  end

  private 
  
  def set_moto_route
      @moto_route = MotoRoute.find(params[:id])
  end
end
