class UsersController < Sinatra::Base

  before do
    content_type 'application/json'
  end

  get '/users' do
    User.all.to_json
  end

  get '/users/:id' do
    @one = User.find params['id']
    @one.to_json
  end

  post '/users' do
    @one = User.new :name => params['name'], :email => params['email'], :pbkdf => 'TODO', :salt => 'TODO'

    if @one.save
      @one.to_json
    else
      {:errors => @one.errors.full_messages}.to_json
    end
  end

end