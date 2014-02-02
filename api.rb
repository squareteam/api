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
      valid = status >= 200 && status < 400
      data = valid ? 'INJECT' : ''
      errors = valid ? '' : 'INJECT'
      wrapper = {:data => data, :errors => errors}.to_json
      body = response.empty? ? '' : response.first
      replace = body.is_a?(String) ? /INJECT/ : /.INJECT./
      response = wrapper.gsub(replace, body)
      headers['Content-Length'] = response.length.to_s
    end
  end

  use PublicController

  use Auth

  use UsersController

end
