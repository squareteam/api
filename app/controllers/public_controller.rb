require File.expand_path 'app/auth/auth.rb'
require File.expand_path 'app/api/errors.rb'
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
