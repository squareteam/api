ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter 'db/'
  add_filter 'vendor/'
  add_filter 'spec/'
end

require File.expand_path '../../api.rb', __FILE__
require File.expand_path '../rspec_mixin.rb', __FILE__
require File.expand_path '../omniauth_mixin.rb', __FILE__

ST_TIMESTAMP_HEADER = 'HTTP_ST_TIMESTAMP'
ST_HASH_HEADER = 'HTTP_ST_HASH'
ST_ID_HEADER = 'HTTP_ST_IDENTIFIER'

# Load FactoryGirl
require 'factory_girl'
FactoryGirl.find_definitions

RSpec.configure do |c|
  c.include RSpecMixin
  c.include OmniauthMixin
  c.include FactoryGirl::Syntax::Methods
end

# Omniauth testing
OmniAuth.config.test_mode = true
