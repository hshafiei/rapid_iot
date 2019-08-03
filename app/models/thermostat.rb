
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

  def self.notfiy_new_reading(reading, thermostat)
    in_store(thermostat)? in_store(thermostat) : get_store_db(thermostat)
    update_stats(reading)
  end

  def self.update_stats(reading)
    for sensor_type in sensor_types
      Stat.update_sensor_stats({sensor_type: sensor_type, thermostat_id: reading.thermostat_id}, reading.send(sensor_type))
    end
  end

  def self.key(args)
    "thermostat_#{args[:id]}"
  end

  def serial_data
    self.to_json
  end

end
