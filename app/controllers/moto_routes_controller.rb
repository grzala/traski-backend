class MotoRoutesController < ApplicationController
  before_action :set_moto_route, only: [:show, :switch_favourite, :vote]

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
    }, :include => [:point_of_interests, :user],
       :with_user => current_user
  end

  def switch_favourite
    err = false
    msgs = []

    if !current_user
      err = true
      msgs << "You must be logged in to perform this action"
    end

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

  def vote
    err = false
    msgs = []

    if !current_user
      err = true
      msgs << "You must be logged in to perform this action"
    end

    if !@moto_route
      err = true
      msgs << "Route of id: #{params[:id]} does not exist"
    end

    if !err
      vote = MotoRouteVote.find_or_initialize_by(user: current_user, moto_route: @moto_route)
      vote.score = params[:score]
      
      
      if !vote.save
        err = true
        msgs.merge!(vote.errors.full_messages)
      else 
        @moto_route.reload # must call this as score was updated
      end
    end


    if err
      return render json: {
        messages: msgs
      }, :status => 401
    end



    render json: {
      messages: ["Thank you for your vote. You voted: #{params[:score]}. Current score is #{@moto_route.score_rounded}/#{MotoRouteVote::MAX_VOTE_SCORE}."],
      score_vote: params[:score],
      current_score: @moto_route.score
    }

  end

  private 
  
  def set_moto_route
      @moto_route = MotoRoute.find(params[:id])
  end
end
