class SessionsController < ApplicationController

    def create
        error = false
        erorr_msg = ""

        user = User.find_by_email(params[:user][:email])
        if (!user)
            error = true
            error_msg = "There is no user with email: " + params[:user][:email]
        end
        
        if (!error)
            if(!user.valid_password?(params[:user][:password]))
                error = true
                error_msg = "Email and password do not match"
            end
        end

        if (error)
            render :json => {
                :error_msgs => [error_msg]
            }, :status => 401
        else
            render :json => {
                :notice => "Successfully logged in as: " + params[:user][:password]
            }
        end
        
        # login_as(@user1, :scope => :user)

        # render :json => {
        #     :asdasdsa => "asdasd"
        # }, :status => 500
    end

    def check_logged_in


        render :json => {
            "yoyoyoyo": "yoyoyoyo"
        }
    end
end
