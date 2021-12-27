
FactoryBot.define do
    
    factory :random_poi, class: 'PointOfInterest' do

        sequence(:name) { |n| "POI #{n}" }
        sequence(:description) { |n| "POI desc #{n} " }
        latitude { rand(20.0..50.0) }
        longitude { rand(20.0..50.0) }
        variant { rand(0..PointOfInterest::MAX_VARIANT) }
    end

end