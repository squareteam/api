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

  # Add a user to a team
  # Receive mandatory data as shown below :
  #   {
  #     'permissions' : 128,
  #     'user_id'     : 1
  #   }
  post '/team/:id/users' do
    team = Team.find params[:id]
    user = User.find params[:user_id]

    if team.nil? || user.nil? || params[:permissions].blank?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      role = UserRole.new(
          user_id: user.id,
          team_id: team.id,
          permissions: params[:permissions].to_i
      )
      if role.save
        status 201
        'ok'.to_json
      else
        status 400
        role.errors.to_json
      end
    end
  end

  # Change user permissions on this team
  # Receive data as shown below :
  #   {
  #     'permissions' : 128
  #   }
  put '/team/:id/user/:user_id' do
    role = UserRole.where(user_id: params[:user_id], team_id: params[:id]).first

    if role.nil? || params[:permissions].blank?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      role.permissions = params[:permissions].to_i
      if role.save
        status 200
        'ok'.to_json
      else
        status 400
        role.errors.to_json
      end
    end
  end

  # Remove user from team
  delete '/team/:id/user/:user_id' do
    role = UserRole.where(user_id: params[:user_id], team_id: params[:id]).first

    if role.nil?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      if role.destroy
        status 200
        'ok'.to_json
      else
        status 400
        role.errors.to_json
      end
    end
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
