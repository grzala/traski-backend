class ApplicationController < ActionController::API
    respond_to :json
    
    def initialize()
        super()
        @err = false
        @msgs = []
    end

    private
end
