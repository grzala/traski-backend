
class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]

    # custom action for devise create user
    def create
        
        user = User.new(user_params)
        field_err_msg = {email: nil, password: nil}

        if (!user.save)
            return render json: {
                messages: user.errors.full_messages,
                field_err_msg: user.errors.to_hash
            }, :status => 401
        end


        render json: {
            messages: ["New account with email: #{user_params[:email]} has been created"],
            id: user.id
        }

    end
  
    protected
  
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, :first_name, :last_name])
    end

    def user_params
        params.require(:user).permit([:email, :password, :password_confirmation, :first_name, :last_name])
    end
  end
  