require 'yodatra/models_controller'

# API controller to serve members
class MembersController < Yodatra::ModelsController
  def read_scope
    self.class.read_scope
  end

  class << self
    def read_scope
      { only: [:id, :organization_id, :user_id, :admin] }
    end
  end
end
