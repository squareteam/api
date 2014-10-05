require 'yodatra/models_controller'

# API controller to manage Teams
# and also manage user_roles through '/teams/:id/users/*' routes
class TeamsController < Yodatra::ModelsController
  disable :read_all

  def read_scope
    self.class.read_scope
  end

  def team_params
    params.select { |k, _| %w(name).include?(k.to_s) }
  end

  class << self
    def limit_read_for(resource, user)
      resource.joins(:users).where(users: { id: user.id })
    end

    def read_scope
      user_read_scope = UsersController.read_scope
      user_read_scope[:only] << :permissions
      {
        # organization_id is needed by the front-end
        #   - avoid unnecessary requests
        only: [:id, :name, :organization_id],
        include: {
          users: user_read_scope
        }
      }
    end
  end

end
