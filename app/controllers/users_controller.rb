require 'yodatra/models_controller'

# API controller to manage Users
class UsersController < Yodatra::ModelsController
  disable :read_all, :create, :delete, :nested_delete, :nested_create, :nested_update

  enable_search_on :name, :email

  # Get my personal information when authenticated
  # @returns your data
  get '/users/me' do
    current_user.as_json(read_scope).to_json
  end

  # Change your password
  # @params {
  #   password: 'new_password'
  # }
  # @returns 200 | 400
  put '/users/me/change_password' do
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
  # @params {
  #     'permissions' : 128,
  #     'id'     : 1
  #   }
  post '/teams/:team_id/users' do
    team = Team.find params[:team_id]
    user = User.find params[:id] || params[:user_id]

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
        role.as_json(self.class.user_roles_read_scope).to_json
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
        role.as_json(self.class.user_roles_read_scope).to_json
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
        role.as_json(self.class.user_roles_read_scope).to_json
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
    # limit access for read depending on the user accessing it
    def limit_read_for(resource, user)
      resource.where(id: user.id)
    end

    def read_scope
      { only: [:id, :name, :email, :provider] }
    end

    def user_roles_read_scope
      { only: [:user_id, :permissions, :team_id] }
    end
  end
end
