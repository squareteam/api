require 'yodatra/base'

class Api < Yodatra::Base
  enable :sessions

  #use Auth
  use UsersController

  #before do
  #  unless session['user_name']
  #    halt "Access denied, please <a href='/login'>login</a>."
  #  end
  #end

  get '/status404' do
    status 404
  end

  get '/:dude' do
    "Hello dude : #{params['dude']}"
  end

  get '/' do
    'Hello Home'
  end
end
