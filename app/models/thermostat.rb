
# == Schema Information
#
# Table name: thermostats
#
#  id                   :integer          not null, primary key
#  household_token      :text
#  location             :text
#  created_at           :datetime
#  updated_at           :datetime
#  uuid                 :varchar
#  number_of_readings   :integer          # This is clearly a redundancy an violates many principles however it reduces the number of access to DB

class Thermostat < ApplicationRecord
  has_many :readings
  has_many :stats

  def self.sensor_types
    ['temperature', 'humidity', 'battery_charge']
  end

  def self.notfiy_new_reading(reading)
    inc_number_of_readings({id: reading.thermostat_id})
    update_stats(reading)
  end

  def self.update_stats(reading)
    for sensor_type in sensor_types
      arg = thermostat_sensor(sensor_type, reading)
      value = reading.send(sensor_type)
      Stat.store_stat(arg, value)
    end
    return true
  end

  def self.thermostat_sensor(type, reading)
    {sensor_type: type, thermostat_id: reading.thermostat_id}
  end

  def self.inc_number_of_readings(args)
    thermostat = fast_find(args)
    fast_update(args, update_args(thermostat)) if thermostat
    return fast_find(args)
  end

  def self.update_args(thermostat)
    {'number_of_readings' => extract_number_of_readings(thermostat) + 1}
  end

  def self.extract_number_of_readings(args)
    args['data']['number_of_readings'] rescue 1
  end

  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:id]}"
  end

  def self.find_in_db(args)
    where(id: args[:id]).first rescue false
  end

end
