require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Teams controller' do

  context 'with an authenticated request' do

    before do
      @user = create :user
      @organization = create :organization
      @organization.add_admin @user

      authenticate_requests_as @user
    end

    describe 'POST a team in a organization' do

      it 'responds with the data of the team' do

        expect {
          post "/organizations/#{@organization.id}/teams", {:name => 'developers'}
          expect(last_response).to be_ok
        }.to change(Team, :count).by(1)
        expect(last_response.body).to include(Team.last.to_json(TeamsController.read_scope))

      end

      context 'with an already taken name' do
        before do
          create :team, organization: @organization, name: 'developers'
        end

        it 'responds with an error message' do

          expect {
            post "/organizations/#{@organization.id}/teams", {:name => 'developers'}
            expect(last_response).to_not be_ok
            expect(last_response.body).to match(/api.already_taken/)
          }.not_to change(Team, :count)

        end
      end

    end

  end

end
