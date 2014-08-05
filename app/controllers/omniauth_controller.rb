require 'sinatra/cookies'
require File.expand_path 'app/auth/auth.rb'
require File.expand_path 'app/api/errors.rb'

# Takes care of omniauth callbacks
class OmniauthController < Sinatra::Base
  helpers Sinatra::Cookies
  OAUTH_TIMEOUT = ENV['OAUTH_TIMEOUT'] || (30)

  # Generic oauth callback
  get '/auth/:provider/callback' do
    one = User.send "find_or_create_from_#{params[:provider]}", auth_hash
    url = Squareteam::Application::CONFIG.app_url
    if one.nil?
      path = '/#/register'
    else
      if one.valid?
        oauth_token = auth_hash.credentials.token
        # Validity of the oauth_token is OAUTH_TIMEOUT
        Auth.cache.set "#{identifier}:OAUTH", OAUTH_TIMEOUT, oauth_token
        response.set_cookie 'st.oauth', value: oauth_token, expires: Time.now + OAUTH_TIMEOUT, path: '/'
      else
        one = User.find_by_email(one.email) if one.email
      end

      if one && one.valid?
        identifier = one.email
        provider = one.provider
        path = "/#/login?email=#{identifier}&provider=#{provider}"
      else
        path = "/#/error?messages=#{one.errors.messages}"
      end
    end

    redirect "#{url}#{path}"
  end

  private

  # Standard for oauth hash information
  # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
  def auth_hash
    request.env['omniauth.auth']
  end
end
