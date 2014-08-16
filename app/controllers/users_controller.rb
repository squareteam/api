require 'yodatra/models_controller'

# API controller to manage Users
class UsersController < Yodatra::ModelsController
  disable :read_all, :create, :delete

  enable_search_on :name, :email

  get '/user/me' do
    current_user.as_json(read_scope).to_json
  end

  put '/user/me/change_password' do
    if params[:password].nil?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      if current_user.change_password(params[:password])
        status 200
        'ok'.to_json
      else
        status 400
        'error'.to_json
      end
    end
  end

  # Add a user to a team
  # Receive mandatory data as shown below :
  #   {
  #     'permissions' : 128,
  #     'user_id'     : 1
  #   }
  post '/teams/:id/users' do
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
  put '/teams/:id/users/:user_id' do
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
  delete '/teams/:id/users/:user_id' do
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
