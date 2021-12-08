class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :moto_routes, dependent: :destroy
  has_many :moto_route_favourites, dependent: :destroy

  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, minimum: 1, allow_blank: false, message: "First name cannot be empty"
  validates_length_of :last_name, minimum: 1, allow_blank: false, message: "Last name cannot be empty"


  before_save :capitalize_name

  def full_name
    self.first_name + " " + self.last_name
  end


  def serializable_hash(options={})
    super.merge ({
      
        :full_name => self.full_name
      
    })
  end

  
  private

  def capitalize_name
    self.first_name = self.first_name.capitalize
    self.last_name = self.last_name.capitalize
  end


end
