class MotoRoutesController < ApplicationController
  before_action :set_moto_route, only: [:show, :switch_favourite, :vote, :get_user_vote, :is_favourite]

  def index
    render json: {
      moto_routes: MotoRoute.all
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  def show
    route_exists?

    if @err
      return render json: {
        messages: @msgs
      }, :status => 401
    end

    render json: {
      moto_route: @moto_route
    }, :include => {:point_of_interests => {}, 
                    :user => {:include_virtual => [:total_routes_added]}},
       :with_user => current_user
  end

  def create

    is_logged_in?

    # puts params[:data]
    # puts params[:waypoints]
    # puts params[:pois]

    field_err_msgs = {}
    field_err_msgs[:pois] = {}
    if !@err
      MotoRoute.transaction do
        data = params[:data]
        @moto_route = MotoRoute.new(
          user: current_user,
          name: data[:name],
          description: data[:description],
          difficulty: data[:difficulty],
          time_to_complete_h: data[:time_to_complete_h],
          time_to_complete_m: data[:time_to_complete_m],
          date_open_day: data[:date_open][:day],
          date_open_month: data[:date_open][:month],
          date_closed_day: data[:date_closed][:day],
          date_closed_month: data[:date_closed][:month],
          open_all_year: data[:open_all_year],
        )
        @moto_route.coordinates = params[:waypoints]

        if !@moto_route.save
          @err = true

          field_err_msgs[:moto_route] = @moto_route.errors.to_hash
          raise ActiveRecord::Rollback
        end

        pois = params[:pois]
        pois.each do |poi|
          new_poi = PointOfInterest.new(
            moto_route: @moto_route,
            name: poi[:name],
            description: poi[:description],
            coordinates: poi[:coordinates],
            variant: poi[:variant],
          )

          if !new_poi.save
            @err = true

            field_err_msgs[:pois][poi[:id]] = new_poi.errors.to_hash
          end
        end

        if @err then raise ActiveRecord::Rollback end
      end
    end

    if @err
      return render json: {
        messages: @msgs,
        field_err_msgs: field_err_msgs,
      }, :status => 401
    end


    render json: {
      messages: ["Route created successfully"],
      new_id: @moto_route.id
    }
  end



  def switch_favourite
    is_logged_in?
    route_exists?
    
    if @err
      return render json: {
        messages: @msgs
      }, :status => 401
    end

    fav = MotoRouteFavourite.find_by(user: current_user, moto_route: @moto_route)
    fav_status = false

    # Switch favourites means favourite is created if not exists and removed if exists
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

  def is_favourite
    is_logged_in?
    route_exists?

    if @err
      return render json: {
        messages: @msgs
      }, :status => 401
    end

    render json: {
      messages: ["Is Favourite query succesful"],
      is_favourite: @moto_route.is_favourite?(current_user)
    }
  end

  def vote
    is_logged_in?
    route_exists?

    if !@err
      vote = MotoRouteVote.find_or_initialize_by(user: current_user, moto_route: @moto_route)
      vote.score = params[:score]
      
      if !vote.save
        @err = true
        @msgs += vote.errors.full_messages
      else 
        @moto_route.reload # must call this as score was updated
      end
    end

    if @err
      return render json: {
        messages: @msgs
      }, :status => 401
    end

    render json: {
      messages: ["Thank you for your vote. You voted: #{params[:score]}. Current score is #{@moto_route.score_rounded}/#{MotoRouteVote::MAX_VOTE_SCORE}."],
      score_vote: params[:score],
      current_score: @moto_route.score
    }
  end

  def get_user_vote
    is_logged_in?
    route_exists?

    if @err
      return render json: {
        messages: @msgs
      }, :status => 401
    end
    
    score = nil
    vote = MotoRouteVote.find_by(user: current_user, moto_route: @moto_route)
    if vote
      score = vote.score
    end

    render json: {
      messages: ["Score query successful"],
      user_score: score
    }
  end

  private 
  
  def set_moto_route
      @moto_route = MotoRoute.find_by(id: params[:id])
  end

  def is_logged_in?
    if !current_user
      @err = true
      @msgs << "You must be logged in to perform this action"
    end
  end

  def route_exists?
    if !@moto_route
      @err = true
      @msgs << "Route of id: #{params[:id]} does not exist"
    end
  end

end
