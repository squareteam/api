require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Public controller' do

  before do

  end

  describe 'registration process' do
    context 'when no password is given' do
      it 'responds with a 400 and an error message' do
        post '/user', {:identifier => 'hello@example.com'}

        last_response.status.should be 400
        expect(last_response.body).to match(/api\.no_password/)
      end
    end
    context 'when no email is given' do
      it 'responds with a 400 and an error message' do
        post '/user', {:password => 'hello@example.com'}

        last_response.status.should be 400
        expect(last_response.body).to match(/api\.violation/)
      end
    end
    context 'when the email has already been taken' do
      before do
        @email_already_taken = 'test@test.fr'
        post '/user', {:password => 'test', :identifier => @email_already_taken, :name => 'test'}
      end

      it 'responds with a 400 and an explicit error message' do
        post '/user', {:password => 'test', :identifier => @email_already_taken, :name => 'test'}

        last_response.status.should be 400
        expect(last_response.body).to match(/api\..*already_taken/)
      end
    end

    context 'when everything is fine' do
      it 'creates a user in the db' do
        expect {
          post('/user', {:password => 'test', :identifier => 'test2@test.fr', :name => ''})
        }.to change(User, :count).by(1)

        last_response.should be_ok
      end
    end
  end

  after do
    User.destroy_all
  end

  describe 'login' do
    context 'with an existing squareteam user' do
      before do
        @existing_identifier = 'test@example.com'
        post '/user', {:password => 'test', :identifier => @existing_identifier, :name => ''}
      end
      it 'responds with two salts and caches the login token' do
        put '/login', {:identifier => @existing_identifier}

        last_response.should be_ok

        user = User.find_by_email(@existing_identifier)
        expect(user.provider).to eql 'squareteam'
        salt = Auth.login(user) # This should only take token and salts from cache as we already logged in
        response_expected = {:salt1 => user.salt.unpack('H*').first, :salt2 => salt.unpack('H*').first}.to_json
        expect(last_response.body).to match(response_expected)
        expect(Auth.cache.get("#{user.email}:TOKEN")).should_not be_nil
      end
    end
    context 'with an external github user (via oauth)' do
      before do
        get '/auth/github/callback', { 'omniauth.auth' => mock_auth_hash }
      end
      it 'responds with two salts and caches the login token' do
        put '/login', {:identifier => 'john@external.com'}

        last_response.should be_ok

        user = User.find_by_email('john@external.com')
        expect(user.provider).to eql 'github'
        user.provider = 'squareteam' # Fake a st user in order to not reset the user's salt
        salt = Auth.login(user) # This should only take token and salts from cache as we already logged in
        response_expected = {:salt1 => user.salt.unpack('H*').first, :salt2 => salt.unpack('H*').first}.to_json
        expect(last_response.body).to match(response_expected)
        expect(Auth.cache.get("#{user.email}:TOKEN")).should_not be_nil
      end
    end
    context 'when the user does not exist' do
      it 'fails with an error message' do
        put '/login', {:identifier => 'none@example.com'}

        last_response.should_not be_ok
        expect(last_response.body).to match(['Login fail'].to_json)
      end
    end
  end

end
