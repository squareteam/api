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
    # Limit access depending on the current_user
    def limit_read_for(projects, user)
      user.accessible_projects(projects)
    end

    def limit_create_for(projects, user)
      p = projects.new
      allowed = true
      allowed = user.has_permission?(UserRole::Permissions::ADD_PROJECT, p.owner) if p.owner.is_a?(Organization)
      allowed ? projects : nil
    end

    alias_method :limit_read_all_for, :limit_read_for
    alias_method :limit_delete_for, :limit_read_for

    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status, :owner_type],
        methods: [:progress, :metadata, :description_md],
        include: {
          owner: UsersController.read_scope
        }
      }
    end
  end

end
