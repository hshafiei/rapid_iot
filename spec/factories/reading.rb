FactoryBot.define do
  factory :reading do
    temperature {Faker::Number.between(1, 10)}
    humidity {Faker::Number.between(1, 10)}
    battery_charge {Faker::Number.between(1, 10)}
    association :thermostat, factory: :thermostat
    household_token {thermostat.house_hold.token}
  end
end
