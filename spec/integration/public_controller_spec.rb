require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Public controller' do

  before do
    allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
    allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
    allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
    allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
  end

  describe 'login' do
    context 'with an existing user' do
      before do
        @existing_identifier = 'test@example.com'
        post '/register', {:password => 'test', :identifier => 'test@example.com'}
      end
      it 'responds with two salts' do
        put '/login', {:identifier => @existing_identifier}

        last_response.should be_ok

        user = User.find_by_email(@existing_identifier)
        response_expected = {:salt1 => user.salt, :salt2 => Auth.generate_token(user.email, user.pbkdf)}.to_json
        expect(last_response.body).to eq(response_expected)
      end
    end
    context 'when the user does not exist' do
      it 'fails with an error message' do
        put '/login', {:identifier => 'none@example.com'}

        last_response.should_not be_ok
        expect(last_response.body).to eq(['Login fail'].to_json)
      end
    end
  end

end