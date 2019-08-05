module RedisStorage
  extend ActiveSupport::Concern

  def self.store(key, data)
    with_rescue do
      true if $redis.set(key, data) == 'OK'
    end
  end

  def self.retrieve(key)
    with_rescue do
      data = $redis.get(key)
      return JSON.parse(data) if data
    rescue JSON::ParserError => e
      return nil
    end
  end

  private
  def self.with_rescue
    yield
  rescue Redis::CannotConnectError => e
    return false
  end
end
