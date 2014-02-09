ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'

require File.expand_path '../../api.rb', __FILE__

ST_TIMESTAMP_HEADER = 'HTTP_ST_TIMESTAMP'
ST_HASH_HEADER = 'HTTP_ST_HASH'
ST_ID_HEADER = 'HTTP_ST_IDENTIFIER'

module RSpecMixin
  include Rack::Test::Methods
  def app
    Api
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
