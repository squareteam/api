require 'yodatra/models_controller'

# API controller to serve organizations
class OrganizationsController < Yodatra::ModelsController
  def read_scope
    self.class.read_scope
  end


  post '/organizations/with_admins' do
    if params[:admins].blank?
      status 400
      [Errors::NO_ROUTE].to_json
    else
      organization = Organization.new(organization_params)

      if organization.save
        team  = Team.find_by_id(organization.admin_team_id)

        params[:admins].each do |user_id|
          UserRole.create(
            user_id: user_id,
            team: team,
            permissions: UserRole::Permissions::all
          )
        end

        organization.as_json(read_scope).to_json
      else
        status 400
        organization.errors.full_messages.to_json
      end
    end
  end


  def organization_params
    params.select { |k, v| ["teams_attributes", "users_attributes", "name"].include?(k) }
  end

  class << self
    def read_scope
      {
        only: [:id, :name, :admin_team_id],
        include: {
          users: UsersController.read_scope#,
          # admins: UsersController.read_scope
        }
      }
    end
  end
end
