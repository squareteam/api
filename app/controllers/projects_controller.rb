require 'yodatra/models_controller'

class ProjectsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  def project_params
    params.select { |k, _| %w(title description deadline status).include?(k.to_s) }
  end

  class << self
    def read_scope
      {
        only: [:id, :title, :description, :deadline, :created_at, :status],
        # TODO include :
        #   - missions  number
        #   - members   number
        #   - documents number
      }
    end
  end

end
