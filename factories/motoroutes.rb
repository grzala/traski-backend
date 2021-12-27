

def create_random_coords_string
    result = []
    
    (0..rand(2..15)).each do
        result << {lat: rand(20.0..50.0), lng: rand(20.0..50.0)}
    end

    return result.to_json
end


FactoryBot.define do
    
    factory :useless_moto_route, class: 'MotoRoute' do
        name { "password" }
        description { "password" }
        coordinates_json_string { create_random_coords_string }
        open_start { Time.at(rand * Time.now.to_i) }
        open_end { Time.at(rand * Time.now.to_i) }
        time_to_complete_h { rand(0...100) }
        time_to_complete_m { rand(0...60) }
        difficulty { rand(1..10) }
        score { rand(0.0..5.0) }
    end

end