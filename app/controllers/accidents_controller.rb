class AccidentsController < ApplicationController

    def get_filtered
        err = false
        msgs = []

        if params[:date_to] == nil || params[:date_from] == nil
            err = true
            msgs << "Please specify a date range"
        end

        if params[:filters] == nil || (params[:filters][:NONE].nil? || params[:filters][:LIGHT].nil? || params[:filters][:HEAVY].nil? || params[:filters][:DEATH].nil?)
            err = true
            msgs << "Please specify filters"
        end

        if !err
            date_from = DateTime.parse(params[:date_from])
            date_to = DateTime.parse(params[:date_to])

            if date_from > date_to
                err = true
                msgs << "Date from cannot be bigger than date to"
            end
        end

        accidents = []
        if !err
            if params[:filters][:NONE]
                accidents += Accident.where({
                    date: date_from..date_to,
                }).NONE
            end

            if params[:filters][:LIGHT]
                accidents += Accident.where({
                    date: date_from..date_to,
                }).LIGHT
            end

            if params[:filters][:HEAVY]
                accidents += Accident.where({
                    date: date_from..date_to,
                }).HEAVY
            end

            if params[:filters][:DEATH]
                accidents += Accident.where({
                    date: date_from..date_to,
                }).DEATH
            end
        end


        if err 
            return render json: {
                messages: msgs
            }, :status => 400
        end



        render json: {
            messages: ["Returned all accidents"],
            accidents: accidents
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
