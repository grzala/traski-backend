

def create_random_coords
    result = []
    
    (0..rand(2..15)).each do |i|
        result << {lat: 20.0 + i, lng: 20.0 + i}
    end

    return result
end

def create_random_pois
    result = []

    return result
end


FactoryBot.define do
    
    factory :useless_moto_route, class: 'MotoRoute' do
        sequence(:name) { |n| "Route lorem ipsum #{n}" }
        sequence(:description) { |n| "Route description lorem ipsum lorem ipsum lorem ipsum #{n} " }
        coordinates { create_random_coords }
        date_open_day { rand(1..25) }
        date_open_month { rand(1..12) }
        date_closed_day { rand(1..25) }
        date_closed_month { rand(1..12) }
        time_to_complete_h { rand(0...23) }
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