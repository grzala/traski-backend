class ApplicationController < ActionController::API
    respond_to :json
    
    def initialize()
        super()
        @err = false
        @msgs = []

        @img_file_prefix = "devel_"
        if Rails.env == "production"
            @img_file_prefix = "prod_"
        end
    end

    private
end
