require 'yodatra/models_controller'

class OrganizationsController < Yodatra::ModelsController
  def read_scope
    {:only => [:id, :name], :include => [:members]}
  end
end