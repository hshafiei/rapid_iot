class HouseHold < ApplicationRecord
  include RedisStore
  after_save :add_to_store

  def add_to_store
    key = "household_#{self.token}"
    RedisStore.store(key, self.tracking_number)
  end

  def self.last_tracking_number(token)
     in_store(token)? in_store(token) : from_db(token).tracking_number.to_i
  end

  def self.in_store(token)
    RedisStore.retrieve("household_#{token}")
  end

  def self.from_db(token)
    where(token: token).first
  end

  def self.inc_tracking_number(token)
    if from_db(token)
      household = from_db(token)
      household.tracking_number += 1
      household.save
    end
  end

end
