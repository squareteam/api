require File.dirname(__FILE__)+'/api'
require 'rack/rewrite'

use Rack::Rewrite do
  rewrite %r{^/\w{2}/api},  '/api'
end

map '/api' do
  run Api
end
