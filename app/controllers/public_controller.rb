require File.expand_path 'app/auth/auth.rb'
require File.expand_path 'app/auth/cache.rb' # for forgotPassword tokens
require File.expand_path 'app/api/errors.rb'
require File.expand_path 'app/mailers/user_mailer.rb' # forgotPassword mail
require 'yodatra/crypto'
require 'digest/sha1'

class PublicController < Yodatra::Base

  before do
    content_type 'application/json'
  end

  get '/' do
    "hello world".to_json
  end

  put '/login' do
    login params[:identifier]
  end

  post '/user' do
    if params[:password].nil?
      status 400
      halt [Errors::NO_PASSWORD_PROVIDED].to_json
    end

    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(params[:password])
    email = params[:identifier]||params[:email]
    uid = email.nil? ? nil : Digest::SHA1.hexdigest(email)
    @one = User.new(
      :uid => uid,
      :provider => 'squareteam',
      :email => email,
      :pbkdf => pbkdf,
      :salt => salt,
      :name => params[:name]
    )

    if @one.save
      login @one.email
    else
      status 400
      @one.errors.full_messages.to_json
    end
  end
  
  post '/forgotPassword' do

    if params[:email].nil?
      status 400
      halt [Errors::UNAUTHORIZED].to_json # TODO : change
    end

    user = User.find_by_email(params[:email])

    if user.nil?
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    cache = Cache.new
    token = SecureRandom.hex

    cache.set("forgotPassword:#{token}", 300, user.id)

    if UserMailer.forgot_password(user, token).deliver
      'forgotPassword.emailSent'.to_json
    else
      # TODO
      status 500
      'api.unavailable'.to_json
    end

  end

  post '/forgotPassword/change' do

    if params[:token].nil? || params[:password].nil?
      status 400
      halt [Errors::UNAUTHORIZED].to_json # TODO : change
    end

    cache = Cache.new

    user_id = cache.get("forgotPassword:#{params[:token]}")

    if user_id.nil?
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    user = User.find(user_id)

    if user.nil?
      status 404
      halt [Errors::NOT_FOUND].to_json
    end

    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(params[:password])
    
    user.pbkdf  = pbkdf
    user.salt   = salt

    if user.save
      cache.rm_cache("forgotPassword:#{params[:token]}")
      cache.rm_cache "#{user.email}:SALT2"
      cache.rm_cache "#{user.email}:TOKEN"

      'forgotPassword.changed'.to_json
    else
      # TODO
      status 500
      'api.unavailable'.to_json
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
