class DbSyncWorker
  require 'concerns/redis_store'
  include Sidekiq::Worker

  def perform(household_token, tracking_number)
    data = RedisStore.retrieve("#{household_token}_#{tracking_number}")
    @reading = Reading.create(data)
    HouseHold.inc_tracking_number(@reading.household_token)
  end
end
