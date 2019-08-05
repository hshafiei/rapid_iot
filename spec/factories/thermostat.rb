FactoryBot.define do
  factory :thermostat do
    number_of_readings {Faker::Number.between(1, 10)}
    location {Faker::Address.street_name}
    association :house_hold, factory: :house_hold
  end
end
