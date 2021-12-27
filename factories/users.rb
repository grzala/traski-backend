first_names = [
    "Adam",
    "Joseph",
    "Nick",
    "Torben",
    "Pietro",
    "Danny",
    "Luigi",
    "Lorenzo",
    "Thanassis",
]

last_names = [
    "Wurzel",
    "Dee",
    "Kilmister",
    "Campbell",
    "Taylor",
    "Clarke",
    "Murray",
    "Smith",
    "Harris",
    "Matziol",
    "Bornemann",
    "Rosenthal"
]



FactoryBot.define do
    
    factory :user do
        sequence(:email, User.next_id) { |n| "user#{n}@mail.com" }
        password { "password" }
        password_confirmation { "password" }
        first_name { first_names.sample }
        last_name { last_names.sample }


        # after :create do |user|
        #     create_list :post, 3, user: user
        # end
    end

end