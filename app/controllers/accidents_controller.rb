class AccidentsController < ApplicationController

    def index
        render json: {
            messages: ["Returned all accidents"],
            accidents: Accident.all
        }
    end

    def bounds
        err = false
        msgs = []


        if !params[:bounds] || !params[:bounds][:northEast] || !params[:bounds][:northEast][:lng] || !params[:bounds][:northEast][:lat]
            err = true
            msgs << "Bounds not passed in request"
        end

        if !err && (!params[:bounds][:southWest] || !params[:bounds][:southWest][:lng] || !params[:bounds][:southWest][:lat])
            err = true
            msgs << "Bounds not passed in request"
        end

        if err 
            return render json: {
                messages: msgs
            }, :status => 400
        end

        # get route bounds, but return a bit wider range
        accidents = Accident.where({
            longitude: (params[:bounds][:southWest][:lng]-0.01)..(params[:bounds][:northEast][:lng]+0.01),
            latitude: (params[:bounds][:southWest][:lat]-0.01)..(params[:bounds][:northEast][:lat]+0.01),
        })

        render json: {
            messages: ["Returned all accidents"],
            accidents: accidents.order("latitude DESC, longitude ASC")
        }
    end
end
