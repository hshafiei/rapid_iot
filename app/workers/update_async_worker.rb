class UpdateAsyncWorker
  require 'concerns/redis_store'
  include Sidekiq::Worker

  # def perform(household_token, tracking_number)
  #   data = RedisStore.retrieve("#{household_token}_#{tracking_number}")
  #   @reading = Reading.create(data)
  #   HouseHold.inc_tracking_number_db(@reading.household_token)
  # end

  def perform(redis_key, update_args)
    hash = RedisStore.retrieve(redis_key)
    obj = hash['class'].classify.constantize.find_by_id(hash['data']['id']) if hash
    obj.update_attributes(update_args) if obj
  end
end
