require 'yodatra/models_controller'

# API controller to serve organizations
class OrganizationsController < Yodatra::ModelsController
  # def read_scope
  #   self.class.read_scope
  # end

  def organization_params
    params.select { |k, v| ["teams_attributes", "users_attributes", "name"].include?(k) }
  end

  class << self
    def read_scope
      {
        only: [:id, :name],
        include: {
          users: UsersController.read_scope#,
          # admins: UsersController.read_scope
        }
      }
    end
  end
end
