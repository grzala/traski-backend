class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :moto_routes, dependent: :destroy
  has_many :moto_route_favourites, dependent: :destroy
  has_many :moto_route_votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, minimum: 1, allow_blank: false, message: "First name cannot be empty"
  validates_length_of :last_name, minimum: 1, allow_blank: false, message: "Last name cannot be empty"
  validates_length_of :first_name, maximum: 15, allow_blank: false, message: "First name cannot be longer than 15"
  validates_length_of :last_name, maximum: 15, allow_blank: false, message: "Last name cannot be longer than 15"


  before_save :capitalize_name

  def full_name
    self.first_name + " " + self.last_name
  end


  def total_routes_added
    MotoRoute.where(user: self).count
  end

  def serializable_hash(options={})
    to_return = super.merge ({
        :full_name => self.full_name
    })

    if options.key?(:include_virtual) && options[:include_virtual].include?(:total_routes_added)

      to_return = to_return.merge ({
        :total_routes_added => self.total_routes_added
    })
    end

    return to_return

  end
  
  private

  def capitalize_name
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
  end


end
