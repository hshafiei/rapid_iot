# == Schema Information
#
# Table name: stats
#
#  id                   :integer          not null, primary key
#  min                  :float
#  max                  :float
#  sum                  :float
#  created_at           :datetime
#  updated_at           :datetime
#  uuid                 :varchar

class Stat < ApplicationRecord
  belongs_to :thermostat
  after_create :save_in_redis

  def self.store_stat(args, value)
    compare_values(args, value)
  end

  def self.compare_values(args, value)
    stat = fast_find(args)

    if stat
      thermostat = Thermostat.fast_find({id: thermostat_id(stat)})
      hash = {}
      hash[:max] = value if value > extract_from_hash(stat, 'max')
      hash[:min] = value if value < extract_from_hash(stat, 'min')
      hash[:sum] = extract_from_hash(stat, 'sum') + value
      hash[:avg] = hash[:sum] / Thermostat.extract_number_of_readings(thermostat) if thermostat
      fast_update(args, hash)
    else
      new_args = merged_hash(args, all_same(value))
      Stat.new(new_args).fast_create
    end
  end

  def self.extract_from_hash(stat, arg)
    stat['data'][arg].to_f
  end

  def self.thermostat_id(stat)
    stat['data']['thermostat_id']
  end

  def self.fast_find_by_id(args)
    stat = fast_find(args)
    stat['data'] if stat
  end


  def self.all_same(value)
    {max: value, min: value, sum: value, avg: value}
  end

  def self.merged_hash(h1, h2)
    h1.merge!(h2)
  end


  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:thermostat_id]}_#{args[:sensor_type]}"
  end

  def self.find_in_db(args)
    where(thermostat_id: args[:thermostat_id], sensor_type: args[:sensor_type]).first rescue false
  end


end
