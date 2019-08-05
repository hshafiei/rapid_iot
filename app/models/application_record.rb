class ApplicationRecord < ActiveRecord::Base
  include RedisStore
  self.abstract_class = true

  after_initialize :add_uuid
  def add_uuid
    self.uuid = SecureRandom.hex(8) rescue nil
  end

  # Checks if redis has the key/value
  def self.find_in_redis(args)
    retrieve_from_redis(self.to_s, args)
  end

  # Gets reading from DB and store it in redis to speedup future requests
  def self.from_db_to_redis(args)
    obj = find_in_db(args)
    if obj
      key = klass.redis_key(klass.name,obj)
      data = obj.serial_data
      klass.store_in_redis(key,data)
      return klass.find_in_redis(args)
    end
  end

  # Returns from DB
  def self.find_in_db(args)
    where(uuid: args[:uuid]).first rescue false
  end

  def fast_create
    self.save_in_redis && self.differed_create
  end

  def self.fast_update(args, update_args)
    update_redis(args, update_args) && differed_update(args, update_args)
  end

  def self.update_redis(args, update_args)
    hash = find_in_redis(args)
    if hash
      merge_hash(hash, update_args)
      store_in_redis(redis_key(self.to_s,args), hash.to_json)
    end
  end

  def differed_create
    CreateAsyncWorker.perform_async(klass.redis_key(self.class.name, self))
  end

  def self.differed_update(args, update_args)
    UpdateAsyncWorker.perform_async(redis_key(self.to_s, args), update_args)
  end

  def self.fast_find(args)
    find_in_redis(args)? find_in_redis(args) : from_db_to_redis(args)
  end

  def klass
    self.class
  end


  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:uuid]}"
  end

  def serial_data
    {class: self.class.name, data: self}.to_json
  end

  def save_in_redis
    klass.store_in_redis(klass.redis_key(self.class.name, self), self.serial_data)
  end

  # Stores in redis
  def self.store_in_redis(key, data)
    RedisStore.store(key, data)
  end

  # Returns data from redis
  def self.retrieve_from_redis(class_name, args)
    RedisStore.retrieve(redis_key(class_name, args))
  end

  def self.merge_hash(hash, update_args)
    hash.merge(hash['data'].merge!(update_args))
  end

  def self.klass
    self
  end

  def self.data_extract(hash)
    hash['data'] if hash && hash['data']
  end

end
