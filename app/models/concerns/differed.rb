module Differed
  extend ActiveSupport::Concern

  def self.create(obj)
    CreateAsyncWorker.perform_async(obj.class.redis_key(obj.class.name, obj))
  end

  def self.update(obj, args, update_args)
    UpdateAsyncWorker.perform_async(obj.redis_key(obj.to_s, args), update_args)
  end
end
