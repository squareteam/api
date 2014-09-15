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
    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status],
        methods: [:progress, :metadata]#,
        # include: {
        #   creator: UsersController.read_scope
        # }
      }
    end
  end

end
