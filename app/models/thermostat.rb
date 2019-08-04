
# == Schema Information
#
# Table name: thermostats
#
#  id                   :integer          not null, primary key
#  household_token      :text
#  location             :text
#  created_at           :datetime
#  updated_at           :datetime

class Thermostat < ApplicationRecord
  has_many :readings
  has_many :stats

  def self.sensor_types
    ['temperature', 'humidity', 'battery_charge']
  end

  def self.notfiy_new_reading(reading)
    update_stats(reading)
  end

  def self.update_stats(reading)
    for sensor_type in sensor_types
      arg = thermostat_sensor(sensor_type, reading)
      value = reading.send(sensor_type)
      Stat.store_stat(arg, value)
    end
  end

  def thermostat_sensor(type, reading)
    {sensor_type: sensor_type, thermostat_id: reading.thermostat_id}
  end

end
