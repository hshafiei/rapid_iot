class CreateAsyncWorker
  require 'concerns/redis_store'
  include Sidekiq::Worker

  # def perform(household_token, tracking_number)
  #   data = RedisStore.retrieve("#{household_token}_#{tracking_number}")
  #   @reading = Reading.create(data)
  #   HouseHold.inc_tracking_number_db(@reading.household_token)
  # end

  def perform(redis_key)
    obj = RedisStore.retrieve(redis_key)
    obj['class'].classify.constantize.create(obj['data']) if obj
  end
end
