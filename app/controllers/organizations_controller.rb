require 'yodatra/models_controller'

# API controller to serve organizations
class OrganizationsController < Yodatra::ModelsController

  def read_scope
    self.class.read_scope
  end

  delete '/organizations/:id/users/:user_id' do
    begin
      organization = Organization.find params[:id]
      user = organization.users.find params[:user_id]
    rescue ActiveRecord::RecordNotFound
      status 400
      return [Errors::BAD_REQUEST].to_json
    end

    teams = Team.where(organization: organization)

    UserRole.destroy_all(:team_id => teams, user: user)
    status 200
    'ok'.to_json
  end

  # Create an organization with admins
  # {
  #  name: 'squareteam' # attributes of organizations
  #  admins_ids: [1,2,3] # Ids of existing users
  # }
  post '/organizations/with_admins' do
    if params[:admins_ids].blank?
      status 400
      [Errors::BAD_REQUEST].to_json
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
    # limit access for read depending on the user accessing it
    def limit_read_for(resource, user)
      resource.joins(:users).where(users: { id: user.id })
    end

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
