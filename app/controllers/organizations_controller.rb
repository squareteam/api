require 'yodatra/models_controller'

# API controller to serve organizationsx
class OrganizationsController < Yodatra::ModelsController
  def read_scope
    self.class.read_scope
  end

  class << self
    def read_scope
      {
        only: [:id, :name],
        include: {
          users: UsersController.read_scope,
          admins: UsersController.read_scope
        }
      }
    end
  end
end
