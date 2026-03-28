FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    category { Faker::Food.ethnic_category }
    cook_time { 20 }
    prep_time { 10 }
    total_time { 30 }
    ratings { 4.5 }
    author { Faker::Internet.username }
    image_url { Faker::Internet.url }
  end
end
