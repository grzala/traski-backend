

def create_random_coords
    result = []
    
    (0..rand(2..15)).each do
        result << {lat: rand(20.0..50.0), lng: rand(20.0..50.0)}
    end

    return result
end

def create_random_pois
    result = []

    return result
end


FactoryBot.define do
    
    factory :useless_moto_route, class: 'MotoRoute' do
        sequence(:name) { |n| "Route #{n}" }
        sequence(:description) { |n| "Route desc #{n} " }
        coordinates { create_random_coords }
        open_start { Time.at(rand * Time.now.to_i) }
        open_end { Time.at(rand * Time.now.to_i) }
        time_to_complete_h { rand(0...100) }
        time_to_complete_m { rand(0...60) }
        difficulty { rand(1..10) }
        score { 0 }

        user { FactoryBot.create(:user) }

        transient do
            with_pois { false }
        end

        after :create do |moto_route, options|
            create_list :random_poi, rand(1..20), moto_route: moto_route if options.with_pois
        end
    end

end