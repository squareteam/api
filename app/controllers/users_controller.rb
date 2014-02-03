require 'yodatra/model_controller'

class UsersController < Yodatra::ModelController

  disable :create, :delete

  # Todo pbkdf and salt
  post '/register' do
    @one = User.new :name => params['name'], :email => params['email'], :pbkdf => 'TODO', :salt => 'TODO'

    if @one.save
      @one.to_json
    else
      status 400
      @one.errors.full_messages.to_json
    end
  end

end