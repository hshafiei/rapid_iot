if !ENV["REDISCLOUD_URL"].blank?
    $redis = Resque.redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
else
  $redis = Redis::Namespace.new("redis_with_rails", :redis => Redis.new)
end
