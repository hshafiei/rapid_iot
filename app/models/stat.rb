class Stat < ApplicationRecord
  include RedisStore
  belongs_to :thermostat

  after_save :add_to_store

  # This updates the redis after saving to the db
  def add_to_store
    self.store_in_redis
  end


  def self.stats(args)
    in_store(args)? in_store(args) : get_store_db(args)
  end

  def self.key(args)
    "thermostat_#{args[:sensor_type]}_#{args[:thermostat_id]}"
  end

  def redis_data
    self
  end

end
