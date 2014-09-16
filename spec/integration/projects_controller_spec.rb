require File.expand_path '../../spec_helper.rb', __FILE__

describe ProjectsController do
  let (:title) { 'new project' }
  let (:description) { 'desc' }

  context 'when authenticated' do
    before do
      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
      User.destroy_all
      @user = User.easy_create(:email => 'projects@test.fr', :password => 'test', :name => 'test')
    end

    describe 'creating a project' do
      it 'creates a project by the current logged in user' do
        expect {
          post '/projects', {title: title, description: description}, {'HTTP_ST_IDENTIFIER' => @user.email}
        }.to change(Project, :count).by(1)

        expect(last_response).to be_ok
        expect(Project.last.creator).to eq @user
        expect(ProjectAccess.last.object_id).to eq @user.id
      end
    end

    describe 'listing of projects' do
      context 'with non accessible projects' do
        before do
          Project.destroy_all
          u = User.easy_create name: 'yo', email: 'yo@yo.fr', password: 'yo'
          u.projects.create title: 'Test project', creator: u
        end
        it 'does not list anything' do
          get '/projects', {}, { 'HTTP_ST_IDENTIFIER' => @user.email }

          expect(last_response).to be_ok
          expect(JSON.parse(last_response.body)['data']).to eq []
        end
      end
      context 'with accessible projects' do
        before do
          Project.destroy_all
          @user.projects.create title: 'Test project', creator: @user
        end
        it 'does not list anything' do
          get '/projects', {}, { 'HTTP_ST_IDENTIFIER' => @user.email }

          expect(last_response).to be_ok
          expect(last_response.body).to include Project.all.as_json(ProjectsController.read_scope).to_json
        end
      end

    end

    describe 'Retrieving a project' do
      before do
        @u = User.easy_create(name: 'john', email: 'john@projects.com', password: 'joh')
        @p = Project.create(title: title, description: description, created_by: @u.id)
      end

      it 'returns all projects information' do
        get "/projects/#{@p.id}", {}, { 'HTTP_ST_IDENTIFIER' => @u.email }

        expect(last_response).to be_ok
        expect(last_response.body).to include Project.find(@p.id).as_json(ProjectsController.read_scope).to_json
      end
    end

    describe 'deleting a project' do
      context 'when you don\'t have access to  it' do
        before do
          @u = User.easy_create(name: 'john', email: 'john@projects.com', password: 'joh')
          @ou = User.easy_create(name: 'marie', email: 'marie@projects.com', password: 'joh')
          @p = Project.create(title: title, description: description, created_by: @ou.id)
        end

        it 'fails with no record found error' do
          expect {
            delete "/projects/#{@p.id}", {}, { 'HTTP_ST_IDENTIFIER' => @u.email }
          }.to_not change(Project, :count)
          expect(last_response).to_not be_ok
          expect(last_response.body).to include 'record not found'
        end
      end
      context 'when you have access to it' do
        before do
          @u = User.easy_create(name: 'john', email: 'john@projects.com', password: 'joh')
          @ou = User.easy_create(name: 'marie', email: 'marie@projects.com', password: 'joh')
          @p = Project.create(title: title, description: description, created_by: @u.id)
        end

        it 'fails with no record found error' do
          expect {
            delete "/projects/#{@p.id}", {}, { 'HTTP_ST_IDENTIFIER' => @u.email }
          }.to change(Project, :count).by(-1)

          expect(last_response).to be_ok
        end
      end
    end
  end
end
