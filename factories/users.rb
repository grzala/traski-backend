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


if ActiveReco7rd::Base.connection.data_source_exists? 'users'
    FactoryBot.define do
        factory :user do
            sequence(:email, User.last.nil? ? 1 : User.last.id + 1) { |n| "test#{n}@mail.com" }
            password { "testtest" }
            password_confirmation { "testtest" }
            first_name { first_names.sample }
            last_name { last_names.sample }


            # after :create do |user|
            #     create_list :post, 3, user: user
            # end
        end

    end
end