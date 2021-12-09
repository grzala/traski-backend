class CommentsController < ApplicationController
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

        render json: {
            messages: ["Comment has been removed"],
            id: params[:id]
        }

    end
end
