require 'yodatra/models_controller'

# API controller to manage Teams
# and also manage user_roles through '/teams/:id/users/*' routes
class TeamsController < Yodatra::ModelsController
  disable :read_all

  # Return team data + linked user_roles data
  get '/teams/:id/extended' do
    @one = Team.find_by_id(params[:id])
    if @one.nil?
      status 400
      [Errors::NOT_FOUND].to_json
    else
      @one.as_json(extended_read_scope).to_json
    end
  end

  post '/teams/:id/users' do
    
  end

  put '/teams/:id/users/:user_id' do
    
  end

  delete '/teams/:id/users/:user_id' do
    
  end

  def read_scope
    self.class.read_scope
  end

  def team_params
    params.select { |k, _| %w(name).include?(k.to_s) }
  end

  class << self
    def read_scope
      { only: [:id, :name] }
    end
  end

  private

  def extended_read_scope
    {
      only: [:id, :name],
      include: {
        users: UsersController.read_scope#,
        #user_roles: [:id, :user_id, :team_id, :permissions]
      }
    }
  end
end
