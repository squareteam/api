require File.expand_path '../../spec_helper.rb', __FILE__

describe ProjectsController do
  let (:title) { 'new project' }
  let (:description) { 'desc' }

  context 'when authenticated' do
    before do
      @user_orga = create :organization
      @user = create :user
      @user_orga.add_admin @user

      # Another orga where the user has not rights to create a project
      @user_orga_no_permission = create :organization
      @user_orga_no_permission.add_admin @user
      @user_orga_no_permission.user_roles.where(user_id: @user.id).map do |ur|
        ur.delete_permission UserRole::Permissions::ADD_PROJECT
        ur.save
      end

      @orga = create :organization, name: 'Two'

      authenticate_requests_as @user
    end

    describe 'creating a project and updating it' do
      context 'when targeting the /projects route' do
        it 'creates a project by the current logged in user and updates it successfully' do
          expect {
            post '/projects', {title: title, description: description}
          }.to change(Project, :count).by(1)

          expect(last_response).to be_ok
          expect(Project.last.owner).to eq @user
          expect(ProjectAccess.last.object_id).to eq @user.id

          project_id = Project.last.id
          project_params = Project.last.as_json(ProjectsController.read_scope)
          project_params['description'] = 'new _awesome_ description'
          expect {
            put "/projects/#{project_id}", project_params
          }.to change(Project, :count).by(0)

          expect(last_response).to be_ok
          json_response = ''
          expect{
            json_response = JSON.parse last_response.body
          }.to_not raise_error
          expect(json_response['data']['description_md']).to include 'new <em>awesome</em> description'
        end
      end
      context 'through the user\'s organization when he has permission' do
        it 'creates a project owned by the orga and updates it successfully' do

          perm = @user.has_permission? UserRole::Permissions::ADD_PROJECT, @user_orga
          expect(perm).to be_truthy
          expect {
            post "/organizations/#{@user_orga.id}/projects", {title: title, description: description}
          }.to change(Project, :count).by(1)

          p = Project.last
          expect(p.owner).to eq @user_orga
          expect(last_response).to be_ok
          expect(last_response.body).to include description

          project_params = Project.last.as_json(ProjectsController.read_scope)
          project_params['description'] = 'new awesome description'
          expect {
            put "/projects/#{p.id}", project_params
          }.to change(Project, :count).by(0)

          expect(last_response).to be_ok
          expect(last_response.body).to include 'new awesome description'
          expect(p.reload.description).to eq 'new awesome description'
        end
      end
      context 'through the user\s organization without the permissions' do
        it 'fails with not allowed error' do
          perm = @user.has_permission? UserRole::Permissions::ADD_PROJECT, @user_orga_no_permission
          expect(perm).to be_falsy
          expect {
            post "/organizations/#{@user_orga_no_permission.id}/projects", {title: title, description: description}
          }.to change(Project, :count).by(0)

          expect(last_response).to_not be_ok
          expect(last_response.status).to eq 401
        end
      end

      context 'through another organization' do
        it 'fails with not allowed error' do
          expect {
            post "/organizations/#{@orga.id}/projects", {title: title, description: description}
          }.to change(Project, :count).by(0)

          expect(last_response).to_not be_ok
        end
      end
    end

    describe 'listing of projects' do
      context 'with non accessible projects' do
        before do
          create :project, :owned_by_user
        end
        it 'does not list anything' do
          get '/projects'

          expect(last_response).to be_ok
          expect(JSON.parse(last_response.body)['data']).to eq []
        end
      end
      context 'with accessible projects' do
        before do
          create :project, owner: @user
        end
        it 'lists my projects' do
          get '/projects'

          expect(last_response).to be_ok
          expect(last_response.body).to include Project.all.as_json(ProjectsController.read_scope).to_json
          expect(Project.count).to be 1
        end
      end

    end

    describe 'Retrieving a project' do
      context 'owned by a user' do
        before do
          @p = create :project, :owned_by_user
          @u = @p.owner

          authenticate_requests_as @u
        end

        it 'returns all projects information' do
          get "/projects/#{@p.id}", {}

          expect(last_response).to be_ok
          expect(last_response.body).to include Project.find(@p.id).as_json(ProjectsController.read_scope).to_json
        end
      end
      context 'owned by an organization' do
        before do
          @p = create :project, :owned_by_organization
          @o = @p.owner
          @u = create :user
          @o.add_admin @u

          authenticate_requests_as @u
        end

        it 'returns all projects information' do
          get "/projects/#{@p.id}"

          expect(last_response).to be_ok
          expect(last_response.body).to include Project.find(@p.id).as_json(ProjectsController.read_scope).to_json
        end
      end
    end

    describe 'deleting a project' do
      context 'when you don\'t have access to  it' do
        before do
          @u = create :user
          @p = create :project, :owned_by_user, title: title, description: description
          @ou = @p.owner

          authenticate_requests_as @u
        end

        it 'fails with no record found error' do
          expect {
            delete "/projects/#{@p.id}"
          }.to_not change(Project, :count)
          expect(last_response).to_not be_ok
          expect(last_response.body).to include 'record not found'
        end
      end
      context 'when you have access to it' do
        before do
          @ou = create :user
          @p = create :project, :owned_by_user, title: title, description: description
          @u = @p.owner

          authenticate_requests_as @u
        end

        it 'fails with no record found error' do
          expect {
            delete "/projects/#{@p.id}"
          }.to change(Project, :count).by(-1)

          expect(last_response).to be_ok
        end
      end
    end
  end
end
