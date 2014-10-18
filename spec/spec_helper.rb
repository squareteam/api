ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter 'db/'
  add_filter 'vendor/'
  add_filter 'spec/'
end

# Load FactoryGirl
require 'factory_girl'
FactoryGirl.find_definitions

# Load DatabaseCleaner
require 'database_cleaner'

require File.expand_path '../../api.rb', __FILE__
require File.expand_path '../rspec_mixin.rb', __FILE__
require File.expand_path '../omniauth_mixin.rb', __FILE__

# Rspec Mixin module for Squareteam's Auth mock
module SquareteamAuthMixin
  def authenticate_requests_as(user)
    allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
    allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
    allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
    allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    allow_any_instance_of(Auth::Request).to receive(:identifier).and_return(user.email)
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
  c.include OmniauthMixin
  c.include FactoryGirl::Syntax::Methods
  c.include SquareteamAuthMixin

  c.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  c.before(:each) do
    DatabaseCleaner.start
  end

  c.after(:each) do
    DatabaseCleaner.clean
  end
end

# Omniauth testing
OmniAuth.config.test_mode = true
