require File.expand_path 'app/auth/auth.rb'
require File.expand_path 'app/api/errors.rb'
require 'yodatra/crypto'

class PublicController < Yodatra::Base

  before do
    content_type 'application/json'
  end

  get '/' do
    "hello world".to_json
  end

  put '/login' do
    @one = User.find_by_email(params[:identifier])

    if @one.nil?
      status 400
      halt [Errors::LOGIN_FAIL].to_json
    end

    salt2 = Auth.generate_token(@one.email, @one.pbkdf)
    {:salt1 => @one.salt.unpack('H*').first, :salt2 => salt2.unpack('H*').first}.to_json
  end

  post %r{/register|/user} do
    if params[:password].nil?
      status 400
      halt [Errors::NO_PASSWORD_PROVIDED].to_json
    end

    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(params[:password])
    @one = User.new :email => params[:identifier]||params[:email], :pbkdf => pbkdf, :salt => salt, :name => params[:name]

    if @one.save
      @one.as_json(:except => [:pbkdf, :salt]).to_json
    else
      status 400
      @one.errors.full_messages.to_json
    end
  end



end