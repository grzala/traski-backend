FactoryBot.define do
  factory :accident do
    lat { 1.5 }
    lng { 1.5 }
    date { "" }
    original_id { "MyString" }
    injury { 1 }
  end
end
