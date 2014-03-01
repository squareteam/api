require 'redis'

class Cache

  def initialize(url = nil)
    @redis = ::REDIS_CONFIG ? Redis.new(::REDIS_CONFIG) : Redis.new
  end

  def set(key, timeout, data)
    @redis.setex(key, timeout, data)
  end

  def get(key)
    @redis.get key
  end

  def rm_cache(*keys)
    @redis.del keys
  end

  def expire(key, timeout)
    @redis.expire key, timeout
  end

  # Try to get item from cache, if fail, use given method, cache value and
  # return it
  def auto_exhume(key, timeout, &block)
    value = get key
    if value.nil?
      value = yield
      set key, value, timeout
    end
    value
  end

  # Delete all item with the given key scheme.
  def purge_cache pattern
    all_keys = @redis.keys pattern
    @redis.del all_keys
  end

end
