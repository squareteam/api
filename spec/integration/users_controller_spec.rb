require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Users controller' do
  context 'with no authentification' do
    it 'responds with a 401 not authorized' do
      get '/users/me'

      expect(last_response.status).to be 401
    end
  end
  context 'with an authenticated request' do

    before do
      @existing_user = create :user
      @organization = create :organization

      authenticate_requests_as @existing_user
    end

    describe 'GET my profile' do
      it 'responds with my profile' do
        get '/users/me'

        expect(last_response).to be_ok
        expect(JSON.load(last_response.body)['data']).to eq(@existing_user.attributes.select{ |k,v| UsersController.read_scope[:only].include? k.to_sym })
      end
    end

    describe 'Changing my password' do
      context 'when no parameters given' do
        it 'responds with an error message' do
          put '/users/me/change_password'

          expect(last_response).to_not be_ok
        end
      end
      context 'when a new password is given in params' do
        it 'succeeds and responds ok' do
          put '/users/me/change_password', {password: 'new'}

          expect(last_response).to be_ok
        end
      end
    end

    describe 'user_role endpoints' do

      before do
        @team = @organization.teams.create(name: 'developers')
      end

      describe 'Adding a user in a team' do
        it 'creates the user_role record' do

          expect {
            post "/teams/#{@team.id}/users", {:permissions => 0, :user_id => @existing_user.id}
          }.to change(UserRole, :count).by(1)
          expect(last_response.status).to be 201

          @team.reload
          expect(@team.users).to include(@existing_user)
        end
      end

      describe 'Updating a user\'s permissions inside a team' do
        before do
          create :user_role, user: @existing_user, team: @team, permissions: 0
        end

        it 'updates the user_role record' do
          put "/teams/#{@team.id}/users/#{@existing_user.id}", { :permissions => 2 }
          expect(last_response).to be_ok
          role = UserRole.where(user_id: @existing_user.id, team_id: @team.id).first
          expect(role.permissions).to equal(2)
        end
      end

      describe 'Removing a user from a team' do
        before do
          create :user_role, user: @existing_user, team: @team, permissions: 0
        end

        it 'deletes the user_role record' do
          expect {
            delete "/teams/#{@team.id}/users/#{@existing_user.id}"
          }.to change(UserRole, :count).by(-1)
          expect(last_response).to be_ok

          role = UserRole.where(user_id: @existing_user.id, team_id: @team.id).first
          expect(role).to be_nil
        end
      end

    end
  end
end
