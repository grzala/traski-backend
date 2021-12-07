class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def full_name
    self.first_name + " " + self.last_name
  end


  def as_json(options={})
    super.merge ({
      
        :full_name => self.full_name
      
    })
  end
end
