Squareteam::Application.configure do |config|
  config.oauth = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + "/../oauth.yml")).result).symbolize_keys
end