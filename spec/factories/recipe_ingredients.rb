FactoryBot.define do
  factory :recipe_ingredient do
    association :recipe
    name { "1 cup #{Faker::Food.ingredient}" }
  end
end
