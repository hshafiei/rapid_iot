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
  validates_presence_of :thermostat_id, :sensor_type
  after_create :fast_save

  def self.store_stat(args, value)
    compare_values(args, value)
  end

  # First finds the stat row based on sensor_type and thermostat_id and calculates max, min,sum and avg and stores them
  def self.compare_values(args, value)
    stat = fast_find(args)
    if stat
      hash = calculate_stats(value, stat)
      fast_update(args, hash)
    else
      new_args = merged_hash(args, all_same(value))
      Stat.new(new_args).fast_create
    end
  end

  # Stats calculations
  def self.calculate_stats(value, stat)
    thermostat = Thermostat.fast_find({id: thermostat_id(stat)})
    hash = {}
    hash[:max] = value if value > extract_from_hash(stat, 'max')
    hash[:min] = value if value < extract_from_hash(stat, 'min')
    hash[:sum] = extract_from_hash(stat, 'sum') + value
    hash[:avg] = hash[:sum] / Thermostat.extract_number_of_readings(thermostat) if thermostat
    return hash
  end

  def self.extract_from_hash(stat, arg)
    stat['data'][arg].to_f
  end

  def self.thermostat_id(stat)
    stat['data']['thermostat_id']
  end

  # Finds the stat by the given arg
  def self.fast_find_by(args)
    puts args
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
