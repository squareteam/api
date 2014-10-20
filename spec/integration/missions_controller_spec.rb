require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe MissionsController do
  context 'with an authenticated request' do
    before do
      @user = create :user
      @project = create :project, owner: @user

      authenticate_requests_as @user
    end

    describe 'Listing missions of your project' do
      before do
        # Yours
        create_list :mission, 3, project: @project
        # Any other
        create_list :mission, 3
      end
      it 'responds with all the missions' do
        get '/missions'

        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body)['data'].count).to eq(3)
      end
    end

    describe 'Creating a mission in a project you own' do
      it 'responds with the data of the newly created mission' do
        expect {
          post "/projects/#{@project.id}/missions", title: 'Mission'
          expect(last_response).to be_ok
        }.to change(Mission, :count).by(1)

        expect(last_response.body).to include(Mission.last.to_json(MissionsController.read_scope))
      end
    end
    describe 'Creating a mission in a project you don\'t have access' do
      before do
        @o_project = create :project, :owned_by_organization
      end
      it 'responds with an error' do
        expect {
          post "/projects/#{@o_project.id}/missions", title: 'Mission'
          expect(last_response).to_not be_ok
        }.to change(Mission, :count).by(0)
        expect {
          post "/missions", { title: 'Mission', project_id: @o_project.id }
          expect(last_response).to_not be_ok
        }.to change(Mission, :count).by(0)
      end
    end
    describe 'Creating a mission in a project without mission_creation rights' do
      before do
        @o_project = create :project, :owned_by_organization
        @o = @o_project.owner
        @o.add_admin @user

        role = @user.user_roles.first
        role.delete_permission UserRole::Permissions::ADD_MISSION
        role.save
      end
      it 'responds with an error' do
        expect {
          post "/projects/#{@o_project.id}/missions", title: 'Mission'
          expect(last_response).to_not be_ok
        }.to change(Mission, :count).by(0)
      end
    end
  end
end
