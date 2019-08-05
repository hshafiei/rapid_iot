FactoryBot.define do
  factory :house_hold do
    token { SecureRandom.hex(10) }
    tracking_number {Faker::Number.between(1, 10)}
  end
end
