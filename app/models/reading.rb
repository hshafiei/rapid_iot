
# == Schema Information
#
# Table name: readings
#
#  id                   :integer          not null, primary key
#  thermostat_id        :integer
#  tracking_number      :integer
#  temperature          :float
#  humidity             :float
#  battery_charge       :float
#  created_at           :datetime
#  updated_at           :datetime
#  household_token      :text
#  uuid                 :varchar

class Reading < ApplicationRecord
  extend RedisStore
  belongs_to :thermostat

  after_save :add_to_store

  # This updates the redis after actually saving to the db
  def add_to_store
    self.store_in_redis
  end

  # According to https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-jobs-input-small-and-simple
  # it is not the best practice to pass complex ruby object to sidekiq. We here use Redis as a temporary data store
  # Redis is in-memory so it is fast enough.

  def fast_store
    fill_tracking_number
    if self.store_in_redis
      # To increment the tracking number in the redis, in the case a request before saving in db gets to the server
      HouseHold.inc_tracking_number_store(token: self.household_token)
      differed_save
    end
  end

  # Gets the last tracking_number and increments it
  def fill_tracking_number
    self.tracking_number = HouseHold.last_tracking_number(token: self.household_token) + 1
  end

  # Differs wirting to the db so can the request can scale
  def differed_save
    DbSyncWorker.perform_async(self.household_token, self.tracking_number)
  end

  # Finds readings by tracking_number and household_token the params format is {household_token: 'X', tracking_number: 'Y' }
  # It checks redis first, if it cannot find then tries DB
  def self.find_by_tracking_number(args)
    in_store(args)? in_store(args) : get_store_db(args)
  end


  def key
    "#{self.household_token}_#{self.tracking_number}"
  end

  def redis_data
    self
  end

  # Stores in redis
  def store_in_redis
    RedisStore.store(self.key, self.to_json)
  end

end
