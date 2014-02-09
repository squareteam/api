require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Users controller' do
  context 'with no authentification' do
    it 'responds with a 401 not authorized' do
      get '/users/me'

      last_response.status.should be 401
    end
  end
  describe 'GET my profile' do
    context 'with an authenticated request' do

      before do
        User.destroy_all

        allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
        allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
        allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
        allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)

        @existing_email = 'test@test.fr'
        @existing_user_from_hash = {:name => 'crazy_hat', :email => @existing_email}
        User.create @existing_user_from_hash.merge(:pbkdf => 'fake', :salt => 'fake')
      end

      it 'responds with my profile' do
        get '/users/me', {}, ST_ID_HEADER => @existing_email

        last_response.should be_ok
        expect(last_response.body).to match(@existing_user_from_hash.to_json)
      end
    end
  end
end
