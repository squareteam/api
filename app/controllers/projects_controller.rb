require 'yodatra/models_controller'

class ProjectsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  def project_params
    params[:owner] = current_user if request.post?
    only = %w(title description deadline status owner)
    only.delete('owner') if request.put?
    params.select { |k, _| only.include?(k.to_s) }
  end

  class << self
    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status],
        methods: [:progress, :metadata],
        include: {
          owner: UsersController.read_scope
        }
      }
    end
  end

end
