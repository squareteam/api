require 'yodatra/models_controller'

class ProjectsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  def project_params
    params[:created_by] = current_user.id if request.post?
    params.select { |k, _| %w(title description deadline status created_by).include?(k.to_s) }
  end

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
          creator: UsersController.read_scope
        }
      }
    end
  end

end
