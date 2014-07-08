require 'yodatra/models_controller'

# API controller to manage Teams
# and also manage user_roles through '/teams/:id/users/*' routes
class TeamsController < Yodatra::ModelsController
  disable :read_all

  # Receive data as shown below :
  #   {
  #     'permissions' : 128,
  #     'user_id'     : 1
  #   }
  post '/teams/:id/users' do
    team = Team.find_by_id(params[:id])
    user = User.find_by_id(params[:user_id])

    if team.nil? || user.nil? || params[:permissions].nil?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      role = UserRole.new(
        :user_id => user.id,
        :team_id => team.id,
        :permissions => params[:permissions].to_i
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

  # Receive data as shown below :
  #   {
  #     'permissions' : 128
  #   }
  put '/teams/:id/user_role/:user_id' do
    team = Team.find_by_id(params[:id])
    if team.nil?
      status 400
      [Errors::BAD_REQUEST].to_json
    else

    end
  end

  delete '/teams/:id/users/:user_id' do
    # TODO
  end

  get '/teams/:id/users/:user_id' do
    # TODO
  end

  def read_scope
    self.class.read_scope
  end

  def team_params
    params.select { |k, _| %w(name).include?(k.to_s) }
  end

  class << self
    def read_scope
      {
        only: [:id, :name],
        include: {
          users: UsersController.read_scope
        }
      }
    end
  end

end
