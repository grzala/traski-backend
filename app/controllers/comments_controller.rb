class CommentsController < ApplicationController
    before_action :set_moto_route, only: [:get_for_route, :create]

    def get_for_route
      if !@moto_route
        return render json: {
          messages: ["Route of id: #{params[:moto_route_id]} does not exist"]
        }, :status => 404
      end
  
      render json: @moto_route.comments
    end
  
    def create
        err = false
        msgs = []
  
        if !current_user
          err = true
          msgs << "You must be logged in to perform this action"
        end
  
        if !@moto_route
          err = true
          msgs << "Route with id: #{params[:moto_route_id]} does not exist"
        end
  
        new_comment = nil
        if !err
          new_comment = Comment.new(user: current_user, moto_route: @moto_route, message: params[:message])
          if !new_comment.save
            err = true
            msgs += new_comment.errors.full_messages
          end
        end
  
        if err 
            return render json: {
                messages: msgs
            }, :status => 401
        end
  
        render json: new_comment
  
    end


    def destroy
      err = false
      msgs = []

      if !current_user
          err = true
          msgs << "You have to be logged in to perform this action"
      end

      @comment = Comment.find(params[:id])

      if !@comment
          err = true
          msgs << "Comment of id: #{params[:id]} does not exist"
      elsif @comment.user.id != current_user.id
          err = true
          msgs << "You cannot delete someone else's comment"
      end

      if err
          return render json: {
              messages: msgs
          }, :status => 401
      end

      @comment.destroy
      render json: {
          messages: ["Comment has been removed"],
          id: params[:id]
      }

  end
  
    private 

    def set_moto_route
        @moto_route = MotoRoute.find_by(id: params[:moto_route_id])
    end
end
