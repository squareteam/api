REDIS_CONFIG = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + "/../redis.yml")).result).symbolize_keys
