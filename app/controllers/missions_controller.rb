require 'yodatra/models_controller'

class MissionsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  def mission_params
    params[:created_by] = current_user.id if request.post?
    params.select { |k, _| %w(title description deadline status created_by).include?(k.to_s) }
  end

  class << self
    def limit_read_for(missions, user)
      missions.where(project_id: user.accessible_projects.pluck(:id))
    end
    alias_method :limit_read_all_for, :limit_read_for

    def limit_create_for(missions, user)
      m = missions.new
      allowed = !m.project.nil?
      allowed = user.has_permission?(UserRole::Permissions::ADD_MISSION, m.project.owner) if allowed && m.project.owner.is_a?(Organization)
      allowed ? missions : nil
    end

    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status],
        methods: [:progress, :metadata, :description_md]#,
        # include: {
        #   creator: UsersController.read_scope
        # }
      }
    end
  end

end
