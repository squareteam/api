require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Teams controller' do

  context 'with an authenticated request' do

    before do
      Organization.destroy_all
      Team.destroy_all
      UserRole.destroy_all

      @user = User.last || User.create(:email => 'test@test.fr', :pbkdf => 'fff', :salt => 'fff')

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

    describe 'user_role endpoints' do

      before do
        @team = Team.create(organization: @organization, name:'developers')
        @user_role = UserRole.last || UserRole.create(user: @user, team: @team, permissions: 0)
      end

      context 'POST a user in a team' do
        it 'create the user_role record' do

          expect {
            post "teams/#{@team.id}/users", {:permissions => 0, :user_id => @user.id}
            last_response.should be_ok
          }.to change(UserRole, :count)

        end
      end

      context 'PUT a user in a team' do
        it 'update the user_role record' do

          put "teams/#{@team.id}/users/#{@user_role.id}", { :permissions => 2 }
          last_response.should be_ok
          expect(@user_role.permissions).to equal(2)

        end
      end

      context 'DELETE a user in a team' do
        it 'remove the user_role record' do

          expect {
            delete "teams/#{@team.id}/users/#{@user_role.id}"
            last_response.should be_ok
          }.to change(UserRole, :count)

        end
      end

    end
  end

end
