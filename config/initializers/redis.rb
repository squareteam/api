Squareteam::Application.configure do |config|
  config.redis = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + "/../redis.yml")).result).symbolize_keys[Squareteam::Application.environment.to_sym]
end
