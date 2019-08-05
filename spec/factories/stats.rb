FactoryBot.define do
  sensor_types =  ['temperature', 'humidity', 'battery_charge']
  factory :stat do
    thermostat_id { 1 }
    sensor_type { sensor_types.sample }
    avg { 0 }
    min { 0 }
    max { 0 }
    sum { 0 }
    association :thermostat, factory: :thermostat
  end
end
