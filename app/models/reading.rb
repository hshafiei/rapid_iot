class Reading < ApplicationRecord
  extend RedisStore

  # According to https://github.com/mperham/sidekiq/wiki/Best-Practices#1-make-your-jobs-input-small-and-simple
  # it is not the best practice to pass complex ruby object to sidekiq. We here use Redis as a temporary data store
  # Redis is in-memory so it is fast enough.

  def fast_store
    fill_tracking_number
    key = "#{self.household_token}_#{self.tracking_number}"
    if RedisStore.store(key, self.to_json)
       HouseHold.inc_tracking_number_store(self.household_token)
       differ_save
    end
  end

  def fill_tracking_number
    self.tracking_number = HouseHold.last_tracking_number(self.household_token) + 1
  end

  def differ_save
    DbSyncWorker.perform_async(self.household_token, self.tracking_number)
  end

  def self.find_by_tracking_number(params)
    in_store(params)? in_store(params) : from_db(params)
  end

  def self.in_store(p)
    RedisStore.retrieve("#{p[:household_token]}_#{p[:tracking_number]}")
  end

  def self.from_db(p)
    where(household_token: p[:household_token], tracking_number: p[:tracking_number]).first
  end

end
