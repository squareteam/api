ENV['RACK_ENV'] ||= 'test'
require 'rack/test'
require 'rspec'

require File.expand_path '../../api.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app
    Api
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
