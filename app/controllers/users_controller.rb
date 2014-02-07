require 'yodatra/model_controller'
require 'yodatra/crypto'

class UsersController < Yodatra::ModelController

  disable :create, :delete

  # Todo pbkdf and salt
  post '/register' do

    salt, pbkdf = Yodatra::Crypto.generate_pbkdf(params[:password])
    @one = User.new :email => params[:identifier], :pbkdf => pbkdf, :salt => salt

    if @one.save
      @one.to_json
    else
      status 400
      @one.errors.full_messages.to_json
    end
  end

end