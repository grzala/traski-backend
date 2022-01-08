
FactoryBot.define do
    
    factory :random_poi, class: 'PointOfInterest' do

        sequence(:name) { |n| "POI with name #{n}" }
        sequence(:description) { |n| "POI description lorem lorem ipsum psumi #{n} " }
        latitude { rand(20.0..50.0) }
        longitude { rand(20.0..50.0) }
        variant { rand(0..PointOfInterest::MAX_VARIANT) }
    end

end