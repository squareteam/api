require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Organizations controller' do

  context 'with an authenticated request' do

    before do
      User.destroy_all

      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    end

    describe 'GET an organization' do
      it 'responds with the data of the organization' do
        post '/organization', {:name => 'squareteam'}
        existing_organization = Organization.find_by_name('squareteam')

        get "/organization/#{existing_organization.id}", {}

        last_response.should be_ok
        expect(last_response.body).to include(existing_organization.to_json(:only => [:name, :id], :include => [:members]))
      end
    end

    describe 'POST an organization' do
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

  end

end
