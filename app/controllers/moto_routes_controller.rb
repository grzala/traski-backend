require 'open-uri'

class MotoRoutesController < ApplicationController
  before_action :set_moto_route, only: [:show, :switch_favourite, :vote, :get_user_vote, :is_favourite, :update, :destroy, :can_edit]

  def index
    render json: {
      moto_routes: MotoRoute.get_top(0)
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  def get_top
    page_no = Integer params[:page]

    min_page = 1
    total_routes = MotoRoute.all.count
    max_page = (total_routes.to_f / MotoRoute::PER_PAGE_TOP.to_f).ceil

    page_no = min_page if page_no < min_page
    page_no = max_page if page_no > max_page



    render json: {
      moto_routes: MotoRoute.get_top((page_no - 1) * MotoRoute::PER_PAGE_TOP),
      max_page: max_page,
      total_routes: total_routes,
      page: page_no
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  def user_routes
    is_logged_in?

    if @err
      return render json: {
        messages: @msgs,
        field_err_msgs: field_err_msgs,
      }, :status => 401
    end

    page_no = Integer params[:page]

    min_page = 1

    total_routes = MotoRoute.where(user: current_user).count
    max_page = (total_routes.to_f / MotoRoute::PER_PAGE_USER_ROUTES.to_f).ceil

    page_no = min_page if page_no < min_page
    page_no = max_page if page_no > max_page

    render json: {
      moto_routes: MotoRoute.get_user_routes(current_user, (page_no - 1) * MotoRoute::PER_PAGE_USER_ROUTES),
      max_page: max_page,
      total_routes: total_routes,
      page: page_no
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  def user_favourites
    is_logged_in?

    if @err
      return render json: {
        messages: @msgs,
        field_err_msgs: field_err_msgs,
      }, :status => 401
    end

    page_no = Integer params[:page]

    min_page = 1

    total_routes = MotoRouteFavourite.where(user: current_user).count
    max_page = (total_routes.to_f / MotoRouteFavourite::PER_PAGE_USER_FAVOURITES.to_f).ceil

    page_no = min_page if page_no < min_page
    page_no = max_page if page_no > max_page

    render json: {
      moto_routes: MotoRouteFavourite.get_user_favourites(current_user, (page_no - 1) * MotoRouteFavourite::PER_PAGE_USER_FAVOURITES).map(&:moto_route),
      max_page: max_page,
      total_routes: total_routes,
      page: page_no
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
          distance: data[:distance],
        )
        @moto_route.coordinates = params[:waypoints]

        if !@moto_route.save
          @err = true

          field_err_msgs[:moto_route] = @moto_route.errors.to_hash
          @msgs << "Adding route not successful. Please check your inputs and try again later."
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
            @msgs << "Adding route not successful. Please check your inputs and try again later."
          end
        end

        if @err then raise ActiveRecord::Rollback end


        # get thumbnail from google maps api
        begin
          thumbnail_path = Rails.root.join('public', 'route_thumbnails', @moto_route.id.to_s + '.png')
          open(thumbnail_path, 'wb') do |file|
            file << open(params[:google_maps_static_api_url]).read
          end
        rescue => error
          puts error
          @err = true
          @msgs << "Cannot download map thumbnail. Try again later or useless waypoints / points of interest."
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
      id: @moto_route.id
    }
  end

  def get_recent
    render json: {
      moto_routes: MotoRoute.get_most_recent(10)
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  def get_in_area
    routes_in_area = []
    point = params[:point]

    if point.nil?
      return render json: {
        messages: ["Pass a point in relation to which moto routes are returned ({lat: number, lng: number})"],
      }, :status => 400
    end

    all_routes = MotoRoute.all

    enough_routes = 20

    steps = [0.02, 0.06, 0.10]

    tiers = [[], [], []]
    all_routes.each do |route|
      distance_lng = (point[:lng] - route.average_lng)/2.0
      distance_lat = (point[:lat] - route.average_lat)/2.0
      distance_sqr = (distance_lng * distance_lng) + (distance_lat * distance_lat)

      if distance_sqr <= steps[0]
        tiers[0] << {
          route: route,
          distance_sqr: distance_sqr
        }
      elsif distance_sqr <= steps[1]
        tiers[1]<< {
          route: route,
          distance_sqr: distance_sqr
        }
      elsif distance_sqr <= steps[2]
        tiers[2] << {
          route: route,
          distance_sqr: distance_sqr
        }
      end
    end

    tiers[0] = tiers[0].sort_by {|obj| obj[:distance_sqr]}
    tiers[1] = tiers[1].sort_by {|obj| obj[:distance_sqr]}
    tiers[2] = tiers[2].sort_by {|obj| obj[:distance_sqr]}

    i = 0
    while i < tiers.length && routes_in_area.length < enough_routes
      j = 0
      while j < tiers[i].length
        routes_in_area << tiers[i][j][:route]
        j += 1
      end
      i += 1
    end

    render json: {
      moto_routes: routes_in_area
    }, :include => [:point_of_interests],
      :with_poi_count => true
  end

  
  def update

    is_logged_in?
    route_exists?

    field_err_msgs = []

    if !@err && @moto_route.user != current_user
      @err = true
      @msgs << "You cannot edit this route"
    end


    field_err_msgs = {}
    field_err_msgs[:pois] = {}
    if !@err
      MotoRoute.transaction do
        data = params[:data]

        # keep the pois to delete them later
        @existing_pois = @moto_route.point_of_interests.map { |poi| poi }

        @moto_route.user = current_user
        @moto_route.name = data[:name]
        @moto_route.description = data[:description]
        @moto_route.difficulty = data[:difficulty]
        @moto_route.time_to_complete_h = data[:time_to_complete_h]
        @moto_route.time_to_complete_m = data[:time_to_complete_m]
        @moto_route.date_open_day = data[:date_open][:day]
        @moto_route.date_open_month = data[:date_open][:month]
        @moto_route.date_closed_day = data[:date_closed][:day]
        @moto_route.date_closed_month = data[:date_closed][:month]
        @moto_route.open_all_year = data[:open_all_year]
        @moto_route.distance = data[:distance]
        @moto_route.coordinates = params[:waypoints]

        if !@moto_route.save
          @err = true

          field_err_msgs[:moto_route] = @moto_route.errors.to_hash
          @msgs << "Adding route not successful. Please check your inputs and try again later."
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
            @msgs << "Adding route not successful. Please check your inputs and try again later."
          end
        end

        if @err then raise ActiveRecord::Rollback end
        
          # new pois were added, remove previously existing pois
          @existing_pois.each do |poi_to_delete|
            poi_to_delete.destroy
          end
      end
    end

    # get thumbnail from google maps api
    # when editing, this will not rollback transaction, previous snapshot will be used
    begin
      thumbnail_path = Rails.root.join('public', 'route_thumbnails', @moto_route.id.to_s + '.png')
      open(thumbnail_path, 'wb') do |file|
        file << open(params[:google_maps_static_api_url]).read
      end
    rescue => error
      puts error
      @err = true
      @msgs << "Cannot download map thumbnail. Try again later or useless waypoints / points of interest."
    end


    if @err
      return render json: {
        messages: @msgs,
        field_err_msgs: field_err_msgs,
      }, :status => 401
    end

    render json: {
      id: @moto_route.id,
      messages: ["Route edited"]
    }
  end

  def destroy
    is_logged_in?
    route_exists?

    if !@err && @moto_route.user != current_user
      @err = true
      @msgs << "You cannot edit this route"
    end

    if !@err
      @moto_route.destroy
    end



    if @err
      return render json: {
        messages: @msgs,
      }, :status => 401
    end

    render json: {
      messages: ["Route removed"]
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

  def can_edit
    can_edit = current_user != nil && @moto_route != nil && current_user == @moto_route.user

    return render json: {
      can_edit: can_edit
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
