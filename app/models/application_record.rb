class ApplicationRecord < ActiveRecord::Base
  include Differed
  include RedisCrud

  self.abstract_class = true

  after_initialize :add_uuid
  def add_uuid
    self.uuid = SecureRandom.hex(8) rescue nil
  end

  # The following methods will provide Fast CRUD functionality for inherited models

  # First creates a key/value pair in redis and differs actual creation to the background
  def fast_create
    self.fast_save && Differed.create(self)
  end

  # Updates the key/value pair in redis and differs actual update to the background
  def self.fast_update(args, update_args)
    RedisCrud.update(self, args, update_args) && Differed.update(self, args, update_args)
  end

  # Tries to find key/value pair in redis if it can not finds loads it from DB to redis
  # in this way every uniq request only needs ontime of direct access to DB
  def self.fast_find(args)
    RedisCrud.find(self, args)? RedisCrud.find(self, args) : RedisCrud.load_from_db(self, args)
  end

  # This is a call back that each model calls after differed job to synchronize redis with the DB
  def fast_save
    RedisCrud.store_in_redis(self.class.redis_key(self.class.name, self), self.redis_value)
  end

  def fast_destroy
    # Not implemented yet
  end

  # These methods will be overwriten by each model per needs
  # Returns first record from DB by args
  def self.find_in_db(args)
    where(uuid: args[:uuid]).first rescue false
  end
  # The key that redis will use to store and retrieve data
  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:uuid]}"
  end

  #The value in redis's key/value
  def redis_value
    {class: self.class.name, data: self}.to_json
  end

end
