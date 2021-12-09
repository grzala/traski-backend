class Comment < ApplicationRecord
    belongs_to :user
    belongs_to :moto_route

    MAX_LENGTH = 150

    validates_length_of :message, minimum: 1, allow_blank: false, message: "Comment cannot be empty"
    validates_length_of :message, maximum: MAX_LENGTH, allow_blank: false, message: "Comment cannot exceed #{MAX_LENGTH} characters"

    def serializable_hash(options={})
        super.merge ({
            :author => self.user.full_name
        })
    end

end