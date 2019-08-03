class ApplicationRecord < ActiveRecord::Base
  include RedisStore
  self.abstract_class = true

  # Checks if redis has the key/value
  def self.in_store(args)
    retrieve_from_redis(args)
  end

  # Gets reading from DB and store it in redis to speedup future requests
  def self.get_store_db(args)
    obj = from_db(args)
    klass = obj.class # Since we are dealing with class method
    klass.store_in_redis(klass.key(args), obj.redis_data) if obj
    return obj
  end

  # Returns from DB
  def self.from_db(args)
    where(args).first rescue false
  end

  # Stores in redis
  def self.store_in_redis(key, data)
    RedisStore.store(key, data)
  end

  # Returns data from redis
  def self.retrieve_from_redis(args)
    RedisStore.retrieve(key(args))
  end

end
