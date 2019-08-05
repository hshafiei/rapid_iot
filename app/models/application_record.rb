class ApplicationRecord < ActiveRecord::Base
  include RedisStorage
  include Differed
  include RedisCrud

  self.abstract_class = true

  after_initialize :add_uuid
  def add_uuid
    self.uuid = SecureRandom.hex(8) rescue nil
  end


  def fast_create
    self.save_in_redis && Differed.create(self)
  end

  def self.fast_update(args, update_args)
    RedisCrud.update_redis(self, args, update_args) && Differed.update(self, args, update_args)
  end

  def self.fast_find(args)
    RedisCrud.find_in_redis(self, args)? RedisCrud.find_in_redis(self, args) : RedisCrud.from_db_to_redis(self, args)
  end

  def save_in_redis
    RedisCrud.store_in_redis(self.class.redis_key(self.class.name, self), self.serial_data)
  end


  # Returns from DB
  def self.find_in_db(args)
    where(uuid: args[:uuid]).first rescue false
  end

  def self.redis_key(class_name, args)
    "#{class_name}_#{args[:uuid]}"
  end

  def serial_data
    {class: self.class.name, data: self}.to_json
  end





end
