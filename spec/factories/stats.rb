FactoryBot.define do
  factory :stat do
    thermostat_id { 1 }
    sensor_type { "MyString" }
    avg { 1.5 }
    min { 1.5 }
    max { 1.5 }
  end
end
