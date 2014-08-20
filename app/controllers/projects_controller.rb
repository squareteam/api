require 'yodatra/models_controller'

class ProjectsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  def project_params
    params[:created_by] = current_user.id if request.post?
    params.select { |k, _| %w(title description deadline status created_by).include?(k.to_s) }
  end

  class << self
    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status],
        include: {
          creator: UsersController.read_scope,
          users: UsersController.read_scope
        }
        # TODO include :
        #   - missions  number
        #   - members   number
        #   - documents number
      }
    end
  end

end
