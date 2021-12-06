class ApplicationController < ActionController::Base

    def check_logged_in
        render json: {
            "test": "test"
        }
    end
end
