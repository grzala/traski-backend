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
            return render :json => {
                :error_msgs => [error_msg]
            }, :status => 401
        end


        sign_in user, :scope => :user
        render :json => {
            :messages => ["Successfully logged in as: " + params[:user][:password]]
        }
        
    end

    def check_logged_in
        render :json => {
            :logged_in => current_user != nil,
            :user => current_user
        }
    end

    def destroy
        puts "DESTROYNG:"


        render :json => {
            :messages => ["Logout successful"]
        }
    end
end
