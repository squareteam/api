require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Teams controller' do

  context 'with an authenticated request' do

    before do
      Organization.destroy_all
      Team.destroy_all
      UserRole.destroy_all

      @user = User.easy_create(name: 'test', email: 'test@test.fr', password: 'fff')

      @organization = Organization.create(:name => 'test')

      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    end

    describe 'POST a team in a organization' do

      it 'responds with the data of the team' do

        expect {
          post "/organizations/#{@organization.id}/teams", {:name => 'developers'}
          last_response.should be_ok
        }.to change(Team, :count)
        expect(last_response.body).to include(Team.last.to_json(TeamsController.read_scope))

      end

      context 'with an already taken name' do
        before do
          Team.create(organization: @organization, name:'developers')
        end

        it 'responds with an error message' do

          expect {
            post "/organizations/#{@organization.id}/teams", {:name => 'developers'}
            last_response.should_not be_ok
            expect(last_response.body).to match(/api.already_taken/)
          }.not_to change(Team, :count)

        end
      end

    end

  end

end
