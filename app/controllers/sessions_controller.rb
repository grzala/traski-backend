class SessionsController < ApplicationController

    def create
        error = false
        erorr_msg = ""
        field_err_msg = {email: nil, password: nil}

        user = User.find_by_email(params[:user][:email])
        if (!user)
            error = true
            error_msg = "There is no user with email: " + params[:user][:email]
            field_err_msg[:email] = "There is no user with email: " + params[:user][:email]
        end
        
        if (!error)
            if(!user.valid_password?(params[:user][:password]))
                error = true
                error_msg = "Email and password do not match"
                field_err_msg[:password] = "Email and password do not match"
            end
        end

        if (error)
            return render :json => {
                :messages => [error_msg],
                :field_err_msg => field_err_msg
            }, :status => 401
        end


        sign_in user
        render :json => {
            :messages => ["Successfully logged in as: " + user.full_name],
            :user => user
        }
        
    end

    def check_logged_in
        render :json => {
            :logged_in => current_user != nil,
            :user => current_user
        }
    end

    def destroy
        msg = "Already logged out"

        if current_user
            sign_out current_user
            msg = "Logout successful"
        end

        render :json => {
            :messages => [msg]
        }
    end

end
