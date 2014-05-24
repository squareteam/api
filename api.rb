# -*- coding: utf-8 -*-
require 'yodatra/base'
require 'yodatra/logger'
require 'yodatra/api_formatter'
require 'yodatra/throttling'

# ############## #
# Squareteam API #
# ############## #
class Api < Yodatra::Base
  VERSION = '0.1.2'
  config = Squareteam::Application::CONFIG
  use Yodatra::Logger
  use Yodatra::Throttle, redis_conf: config.redis

  # Omniauth
  use Rack::Session::Redis, redis_server: config.redis, :expire_after => 30
  use ::OmniAuth::Builder do
    provider :github, config.oauth[:github]['key'], config.oauth[:github]['secret']
    provider :behance, config.oauth[:behance]['key'], config.oauth[:behance]['secret'], { scope: 'collection_read|wip_read|project_read' }
  end

  # ST api formatter
  use Yodatra::ApiFormatter do |status, headers, response|
    if headers['Content-Type'] =~ /application\/json/
      valid = status >= 200 && status < 300
      data = valid ? '?' : ''
      errors = valid ? '' : '?'
      replace = /.\?./
      body = response.empty? ? '' : response.first
      response = [{:data => data, :errors => errors}.to_json.gsub(replace, body)]
    end
    [status, headers, response]
  end

  # Omniauth callback
  use OmniauthController

  use PublicController

  # ST auth barrier
  use Auth

  use UsersController
  use OrganizationsController
  use MembersController
  use PrivateController

  NO_ROUTE_PROC = lambda do
    status 400
    content_type 'application/json'
    [Errors::NO_ROUTE].to_json
  end

  get //, &NO_ROUTE_PROC
  post //, &NO_ROUTE_PROC
  put //, &NO_ROUTE_PROC
  delete //, &NO_ROUTE_PROC

end
