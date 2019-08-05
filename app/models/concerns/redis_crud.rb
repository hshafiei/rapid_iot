module RedisCrud
  extend ActiveSupport::Concern
  # Updates redis
  def self.update(obj, args, update_args)
    hash = find(obj, args)
    if hash
      merge_hash(hash, update_args)
      store_in_redis(obj.redis_key(obj.to_s,args), hash.to_json)
    end
  end

  # Find keys in redis and returns values
  def self.find(obj, args)
    retrieve_from_redis(obj, obj.to_s, args)
  end

  # Returns data from redis
  def self.retrieve_from_redis(obj, class_name, args)
    RedisStorage.retrieve(obj.redis_key(class_name, args))
  end

  def self.merge_hash(hash, update_args)
    hash.merge(hash['data'].merge!(update_args))
  end

  # Stores in redis
  def self.store_in_redis(key, data)
    RedisStorage.store(key, data)
  end

  # Gets reading from DB and store it in redis to speedup future requests
  def self.load_from_db(caller, args)
    obj = caller.find_in_db(args)
    if obj
      key = obj.class.redis_key(obj.class.name,obj)
      data = obj.redis_value
      store_in_redis(key,data)
      return find(caller, args)
    end
  end

  def self.data_extract(hash)
    hash['data'] if hash && hash['data']
  end


end
