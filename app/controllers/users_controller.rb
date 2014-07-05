require 'yodatra/models_controller'

# API controller to manage Users
class UsersController < Yodatra::ModelsController
  disable :read_all, :create, :delete

  get '/user/me' do
    @one = User.find_by_email(request.env['REMOTE_USER'])
    if @one.nil?
      status 400
      [Errors::ID_NOT_FOUND].to_json
    else
      @one.as_json(read_scope).to_json
    end
  end

  get '/user/search' do
    # TODO(charly): make more secure ...
    User.where("name LIKE '%#{params[:query]}%'").as_json(read_scope).to_json
  end

  def read_scope
    self.class.read_scope
  end

  def user_params
    params.select { |k, _| %w(name email).include?(k.to_s) }
  end

  class << self
    def read_scope
      { only: [:id, :name, :email] }
    end
  end
end
