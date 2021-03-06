require File.expand_path 'app/auth/auth.rb'
require File.expand_path 'app/auth/cache.rb'
require File.expand_path 'app/api/errors.rb' # Load auto with Yodatra?
require File.expand_path 'app/mailers/user_mailer.rb' # Load auto with Yodatra?
require 'yodatra/crypto'
require 'digest/sha1'

class PublicController < Yodatra::Base

  before do
    content_type 'application/json'
    @cache = Cache.new
  end

  get '/' do
    "hello world".to_json
  end

  # Login to the API only with your identifier (email)
  # @params {
  #   identifier: 'john@squareteam.io'
  # }
  # @returns session salts to use for all future API calls
  put '/login' do
    login params[:identifier]
  end

  # Create a new user
  # @params {
  #   name: 'john',
  #   email: 'john@example.com',
  #   ... # Users attributes
  # }
  post '/users' do
    if params[:password].nil?
      status 400
      halt [Errors::NO_PASSWORD_PROVIDED].to_json
    end

    @one = User.easy_new params

    if @one.save
      login @one.email
    else
      status 400
      @one.errors.full_messages.to_json
    end
  end

  # Ask for a forgot password token given your email
  # Token will be sent by email
  # @params {
  #   email: 'john@squareteam.io'
  # }
  # @returns 200 | 404 | 400 Oauth account
  post '/forgot_password' do
    if params[:email].blank?
      status 400
      halt [Errors::BAD_REQUEST].to_json
    end

    user = User.find_by_email(params[:email])

    if user.nil?
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    unless user.provider == 'squareteam'
      status 400
      halt [Errors::OAUTH_ACCOUNT,{provider: user.provider}].to_json
    end

    token = SecureRandom.hex

    @cache.set "#{token}:FORGOT_TOKEN", 300, user.id

    if UserMailer.forgot_password(user, token).deliver
      'ok'.to_json
    else
      # TODO
      status 500
      'api.unavailable'.to_json
    end

  end

  # Changes your password given a valid temporary token
  # @params
  # {
  #   password: 'new_password',
  #   token: 'xxxyyyzzz'
  # }
  # @returns 200 | 404 | 400 Missing params | 500 change impossible
  post '/forgot_password/change' do

    if params[:token].nil? || params[:password].nil?
      status 400
      halt [Errors::BAD_REQUEST].to_json
    end

    user_id = @cache.get "#{params[:token]}:FORGOT_TOKEN"

    if user_id.nil?
      # To follow eventually (attack?)
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    user = User.find_by_id user_id

    if user.nil?
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    if user.change_password(params[:password])
      @cache.rm_cache "#{params[:token]}:FORGOT_TOKEN"
      'ok'.to_json
    else
      # TODO
      status 500
      ['api.unavailable'].to_json
    end

  end

  private

  def login(identifier)
    @one = User.find_by_email(identifier)

    # Login can potentially reset user's pbkdf and salt (if they are connected by oauth)
    salt2 = Auth.login(@one)
    if salt2.nil?
      status 400
      halt [Errors::LOGIN_FAIL].to_json
    else
      # Thus make sure to reload the user
      @one = @one.reload
      {:salt1 => @one.salt.unpack('H*').first, :salt2 => salt2.unpack('H*').first}.to_json
    end
  end
end
