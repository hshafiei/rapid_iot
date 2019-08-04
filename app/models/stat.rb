class Stat < ApplicationRecord
  include RedisStore
  belongs_to :thermostat
  after_create :save_in_redis

  def self.store_stat(args, value)
    compare_values(args, value)
  end

  def self.compare_values(args, value)
    stat = fast_find(args)
    if stat
      hash = {}
      hash[:max] = value if value > extract_from_hash(stat, 'max')
      hash[:min] = value if value < extract_from_hash(stat, 'min')
      #stat.sum = stat.sum + value
      fast_update(args, hash)
    else
      new_args = merged_hash(args, all_same(value))
      Stat.new(new_args).fast_create
    end
  end

  def self.extract_from_hash(stat, arg)
    stat['data'][arg].to_f
  end


  def self.all_same(value)
    {max: value, min: value}
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
