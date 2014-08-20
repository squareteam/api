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
      end
    end

    describe 'Retrieving a project' do
      before do
        @u = @u || User.easy_create(name: 'john', email: 'john@projects.com', password: 'joh')
        @p = @p || Project.create(title: title, description: description, created_by: @u.id)
      end

      it 'returns all projects information' do
        get "/projects/#{@p.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include Project.find(@p.id).as_json(ProjectsController.read_scope).to_json
      end
    end
  end
end
