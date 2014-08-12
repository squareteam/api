require 'yodatra/models_controller'

# API controller to serve organizations
class OrganizationsController < Yodatra::ModelsController

  disable :delete

  def read_scope
    self.class.read_scope
  end

  delete '/organizations/:id/user/:user_id' do
    organization = Organization.find params[:id]
    user = User.find params[:user_id]

    if organization.nil? || user.nil?
      status 400
      [Errors::BAD_REQUEST].to_json
    else
      teams = Team.where(organization: organization)

      UserRole.destroy_all(:team => teams, user: user)
      status 200
      'ok'.to_json
    end
  end

  post '/organizations/with_admins' do
    if params[:admins_ids].blank?
      status 400
      [Errors::NO_ROUTE].to_json
    else
      organization = Organization.new(organization_params)

      if organization.save
        params[:admins_ids].each do |user_id|
          unless User.exists? user_id
            status 400
            return ["Is user #{user_id} real?"].to_json
          end

          organization.add_admin user_id
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
