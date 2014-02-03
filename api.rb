require 'yodatra/base'
require 'yodatra/logger'
require 'yodatra/api_formatter'

require File.expand_path 'app/auth/auth.rb'

class Api < Yodatra::Base
  configure do
    enable :sessions
  end
  use Yodatra::Logger
  use Yodatra::ApiFormatter do |status, headers, response|
    if headers['Content-Type'] =~ /application\/json/
      valid = status >= 200 && status < 300
      data = valid ? '?' : ''
      errors = valid ? '' : '?'
      replace = /.\?./
      body = response.empty? ? '' : response.first
      response = {:data => data, :errors => errors}.to_json.gsub(replace, body)

      headers['Content-Length'] = response.length.to_s
    end
    [status, headers, response]
  end

  use PublicController

  use Auth

  use UsersController

  NO_ROUTE_PROC = lambda do
    status 400
    content_type 'application/json'
    ['Nothing around here'].to_json
  end

  get //, &NO_ROUTE_PROC
  post //, &NO_ROUTE_PROC
  put //, &NO_ROUTE_PROC
  delete //, &NO_ROUTE_PROC

end
