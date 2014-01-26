require 'sinatra/base'
require File.expand_path  '../config/boot', __FILE__
require File.expand_path  '../config/initializers', __FILE__

class Api < Sinatra::Base
  register Sinatra::Boot
  register Sinatra::Initializers

  set :sessions, true

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
    "Hello #{params['dude']}"
  end

  get '/' do
    'Hello Home'
  end
end
