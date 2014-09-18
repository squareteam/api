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

  # Limit access depending on the current_user
  def prepare_read(projects)
    user_access = ProjectAccess.where(object_type: 'User', object_id: current_user.id)
    orga_access = ProjectAccess.where(object_type: 'Organization', object_id: current_user.organizations.pluck(:id))
    user_access = user_access.where_values.reduce(:and)
    orga_access = orga_access.where_values.reduce(:and)
    projects.joins(:project_accesses).where(user_access.or(orga_access)).uniq
  end
  alias :prepare_read_all :prepare_read
  alias :prepare_delete :prepare_read

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
