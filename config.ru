require File.dirname(__FILE__)+'/api'
require 'rack/rewrite'
require 'rack/parser'

use Rack::Parser, :parsers => { 'application/json' => proc { |data| JSON.parse data } }

use Rack::Rewrite do
  rewrite %r{^/\w{2}/api},  '/api'
end

map '/api' do
  run Api
end
