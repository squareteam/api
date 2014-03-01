require 'yodatra/models_controller'

class MembersController < Yodatra::ModelsController

  def read_scope
    {:only => [:id, :organization_id, :user_id, :admin]}
  end

end