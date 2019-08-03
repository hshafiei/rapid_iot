class Stat < ApplicationRecord
  include RedisStore
  belongs_to :thermostat

  after_save :add_to_store

  # This updates the redis after saving to the db
  def add_to_store
    self.store_in_redis
  end


  def self.update_sensor_stats(args, value)
    in_store(args)? in_store(args) : get_store_db(args)
  end

  def compare_values(args, value)
    stat = retrieve_from_redis(args)
    if stat
      stat.max = value if value > stat.max
      stat.min = value if value < stat.min
      #stat.sum = stat.sum + value
      store_in_redis(key(args), stat)
    end
  end

  def self.key(args)
    "thermostat_#{args[:sensor_type]}_#{args[:thermostat_id]}"
  end

  def redis_data
    self.to_json
  end

end
