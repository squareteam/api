require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Organizations controller' do

  context 'with an authenticated request' do

    before do
      Organization.destroy_all

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
        existing_organization.users << @user

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
            expect(last_response).to match /api.swcc_already_taken/
          }.not_to change(Organization, :count)
        end
      end
    end

    describe 'POST an organization nested on a user' do
      before do
        Organization.destroy_all
      end
      it 'responds with the data of the organization' do
        expect {
          post "/user/#{@user.id}/organizations", {:name => 'test_orga'}
          last_response.should be_ok
        }.to change(Organization, :count).by(1)
        expect { Organization.last.users.to include @user }
      end
    end

  end

end
