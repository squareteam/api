require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Organizations controller' do

  context 'with an authenticated request' do

    before do
      Organization.destroy_all
      Team.destroy_all
      Role.destroy_all

      @user = User.last || User.create(:email => 'test@test.fr', :pbkdf => 'fff', :salt => 'fff')

      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    end

    describe 'GET an organization' do
      it 'responds with the data of the organization' do
        post '/organization', {:name => 'squareteam'}
        existing_organization = Organization.find_by_name('squareteam')
        
        # This notation (.users << ...) is no longer supported
        # due to user - organization 3 tables based relation
        # existing_organization.users << @user

        get "/organization/#{existing_organization.id}", {}

        last_response.should be_ok
        expect(last_response.body).to include(existing_organization.to_json(OrganizationsController.read_scope))
      end
    end

    describe 'POST an organization' do
      context 'that does not exist' do
        before do
          Organization.destroy_all
        end
        it 'responds with the data of the organization' do
          expect {
            post '/organization', {:name => 'swcc'}
            last_response.should be_ok
          }.to change(Organization, :count).by(1)
        end
      end
      context 'that already exist' do
        before do
          Organization.destroy_all
          Organization.create(:name => 'swcc')
        end
        it 'responds with an error message' do
          expect {
            post '/organization', {:name => 'swcc'}
            last_response.should_not be_ok
            expect(last_response.body).to match /api.already_taken/
          }.not_to change(Organization, :count)
        end
      end
    end

    describe 'POST /organizations/with_admins' do
      context 'without admins params' do
        before do
          Organization.destroy_all
        end
        it 'responds "400 Bad Request" if no admins given' do
          expect {
            post '/organizations/with_admins', {:name => 'swcc'}
            last_response.should_not be_ok
          }.not_to change(Organization, :count)
        end
      end
      context 'create organization and add given users to "Admins" team' do
        before do
          Organization.destroy_all
          UserRole.destroy_all
        end
        it 'create organization and add given users to "Admins" team' do
          expect {
            post '/organizations/with_admins', {:name => 'swcc', :admins => [1]}
            last_response.should be_ok
          }.to change(Team, :count).by(1)
          expect(Organization.count).to equal(1)
          expect(UserRole.count).to equal(1)
        end
      end
    end


    # DEPRECATED since user - organization use 3 tables, will throw a 
    # "Cannot modify association 'User#organizations' because it goes through more than one other association."
    # 
    # describe 'POST an organization nested on a user' do
    #   before do
    #     Organization.destroy_all
    #   end
    #   it 'responds with the data of the organization' do
    #     expect {
    #       post "/user/#{@user.id}/organizations", {:name => 'test_orga'}
    #       last_response.should be_ok
    #     }.to change(Organization, :count).by(1)
    #     expect { Organization.last.users.to include @user }
    #   end
    # end

  end

end
