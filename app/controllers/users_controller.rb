require 'yodatra/models_controller'

class UsersController < Yodatra::ModelsController

  disable :read_all, :read, :create, :delete

  get '/user/me' do
    @one = User.find_by_email(request.env['REMOTE_USER'])
    if @one.nil?
      status 400
      [Errors::ID_NOT_FOUND].to_json
    else
      @one.as_json(read_scope).to_json
    end
  end

  def read_scope
    {:only => [:id, :name, :email]}
  end
end