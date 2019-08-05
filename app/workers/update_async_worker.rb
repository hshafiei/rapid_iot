class UpdateAsyncWorker
  require 'concerns/redis_store'
  include Sidekiq::Worker

  def perform(redis_key, update_args)
    hash = RedisStore.retrieve(redis_key)
    obj = hash['class'].classify.constantize.find_by_id(hash['data']['id']) if hash
    obj.update_attributes(update_args) if obj
  end
end
