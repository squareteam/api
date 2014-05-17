ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter 'db/'
end

require File.expand_path '../../api.rb', __FILE__
require File.expand_path '../rspec_mixin.rb', __FILE__
require File.expand_path '../omniauth_mixin.rb', __FILE__

ST_TIMESTAMP_HEADER = 'HTTP_ST_TIMESTAMP'
ST_HASH_HEADER = 'HTTP_ST_HASH'
ST_ID_HEADER = 'HTTP_ST_IDENTIFIER'

RSpec.configure do |c|
  c.include RSpecMixin
  c.include OmniauthMixin
end

# Omniauth testing
OmniAuth.config.test_mode = true
