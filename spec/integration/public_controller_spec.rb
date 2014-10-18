require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Public controller' do

  before do
    @r = Redis.new Squareteam::Application::CONFIG.redis
    @cache = Cache.new
    @cache.purge_cache '*'
  end

  describe 'registration process' do
    context 'when no password is given' do
      it 'responds with a 400 and an error message' do
        post '/users', {:identifier => 'hello@example.com'}

        expect(last_response.status).to be 400
        expect(last_response.body).to match(/api\.no_password/)
      end
    end
    context 'when no email is given' do
      it 'responds with a 400 and an error message' do
        post '/users', {:password => 'hello@example.com'}

        expect(last_response.status).to be 400
        expect(last_response.body).to match(/api\.violation/)
      end
    end
    context 'when the email has already been taken' do
      before do
        @email_already_taken = 'test@test.fr'
        post '/users', {:password => 'test', :identifier => @email_already_taken, :name => 'test'}
      end

      it 'responds with a 400 and an explicit error message' do
        post '/users', {:password => 'test', :identifier => @email_already_taken, :name => 'test'}

        expect(last_response.status).to be 400
        expect(last_response.body).to match(/api\..*already_taken/)
      end
    end

    context 'when everything is fine' do
      it 'creates a user in the db' do
        expect {
          post('/users', {:password => 'test', :identifier => 'test2@test.fr', :name => ''})
        }.to change(User, :count).by(1)

        expect(last_response).to be_ok
      end
    end
  end

  describe 'login' do
    context 'with an existing squareteam user' do
      before do
        @existing_identifier = 'test@example.com'
        post '/users', {:password => 'test', :identifier => @existing_identifier, :name => ''}
      end
      it 'responds with two salts and caches the login token' do
        put '/login', {:identifier => @existing_identifier}

        expect(last_response).to be_ok

        user = User.find_by_email(@existing_identifier)
        expect(user.provider).to eql 'squareteam'
        salt = Auth.login(user) # This should only take token and salts from cache as we already logged in
        response_expected = {:salt1 => user.salt.unpack('H*').first, :salt2 => salt.unpack('H*').first}.to_json
        expect(last_response.body).to match(response_expected)
        expect(Auth.cache.get("#{user.email}:TOKEN")).to_not be_nil
      end
    end
    context 'with an external github user (via oauth)' do
      before do
        get '/auth/github/callback', { 'omniauth.auth' => github_auth_hash }
      end
      it 'responds with two salts and caches the login token' do
        put '/login', {:identifier => 'john@external.com'}

        expect(last_response).to be_ok

        user = User.find_by_email('john@external.com')
        expect(user.provider).to eql 'github'
        user.provider = 'squareteam' # Fake a st user in order to not reset the user's salt
        salt = Auth.login(user) # This should only take token and salts from cache as we already logged in
        response_expected = {:salt1 => user.salt.unpack('H*').first, :salt2 => salt.unpack('H*').first}.to_json
        expect(last_response.body).to match(response_expected)
        expect(Auth.cache.get("#{user.email}:TOKEN")).to_not be_nil
      end
    end
    context 'with an external github user (via oauth) that has no public email' do
      it 'is not possible and redirect to the frontend login page with errors in parameters' do
        get '/auth/github/callback', { 'omniauth.auth' => github_auth_hash_without_email }
        expect(last_response.status).to be 302
        expect(last_response['Location']).to include 'login?errors={:email=>'
      end
    end
    context 'when the user does not exist' do
      it 'fails with an error message' do
        put '/login', {:identifier => 'none@example.com'}

        expect(last_response).to_not be_ok
        expect(last_response.body).to match(['Login fail'].to_json)
      end
    end
  end

  describe 'forgot password process' do
    describe 'when requesting a token' do
      before do
        Squareteam::Application::CONFIG.app_url = '' # for UserMailer
      end

      context 'without email param' do
        it 'should respond "400 Bad Request"' do

          post "/forgot_password"

          expect(last_response).to_not be_ok
          expect(last_response.body).to match("api.bad_request".to_json)
        end
      end

      context 'with invalid email' do
        it 'should respond "404 Not Found"' do

          post "/forgot_password", {:email => "notexistent@user.com"}

          expect(last_response).to_not be_ok
          expect(last_response.body).to match("api.not_found".to_json)
        end
      end

      context 'with a valid email' do
        it 'should create a token and sent it to the given email' do
          u = create :user, email:'te@fo.com'
          allow(SecureRandom).to receive(:hex).and_return('abcd')
          expect(UserMailer).to receive(:forgot_password).with(u, 'abcd').and_call_original

          post '/forgot_password', email: 'te@fo.com'

          expect(last_response).to be_ok
          expect(@r.get('abcd:FORGOT_TOKEN')).to_not be_nil
        end
      end

      context 'with a valid email but an oauth account' do
        it 'doesn\'t create a token and returns a 400 with provider in error' do
          u = create :user, email:'test@forgot.com', provider: 'github'
          expect(SecureRandom).to_not receive(:hex)

          post '/forgot_password', email: 'test@forgot.com'

          expect(last_response).to_not be_ok
          expected_response = {provider: 'github'}.to_json
          expect(last_response.body).to match(expected_response)
        end
      end
    end

    describe 'when changing password' do

      context 'with a no token param' do
        it 'should respond "400 Bad Request"' do
          post "/forgot_password/change", {:password => "test"}

          expect(last_response).to_not be_ok
          expect(last_response.body).to match("api.bad_request".to_json)
        end
      end

      context 'with a no password param' do
        it 'should respond "400 Bad Request"' do
          post "/forgot_password/change", {:token => "abcd"}

          expect(last_response).to_not be_ok
          expect(last_response.body).to match("api.bad_request".to_json)
        end
      end

      context 'with an invalid token' do
        it 'responds with "404 Not Found"' do
          post "/forgot_password/change", {
            token: 'abcd',
            password: 'mynewpassword'
          }

          expect(last_response).to_not be_ok
          expect(last_response.body).to match "api.not_found".to_json
        end
      end

      context 'with a token referencing a not existent user' do
        it 'should respond "404 Not Found"' do
          @r.set('abcd:FORGOT_TOKEN', 13)

          post '/forgot_password/change', {
            token: 'abcd',
            password: 'mynewpassword'
          }

          expect(last_response).to_not be_ok
          expect(last_response.body).to match('api.not_found'.to_json)
        end
      end

      context 'with a valid token' do
        before do
          user = create :user, :email => 'test@changepassword.com'
          @r.set('abcd:FORGOT_TOKEN', user.id)
        end

        it 'responds OK and changes the password for the user' do
          post '/forgot_password/change', {
            password: 'newpassword',
            token: 'abcd'
          }

          expect(last_response).to be_ok

          user = User.find_by_email('test@changepassword.com')
          _, pbkdf = Yodatra::Crypto.generate_pbkdf('newpassword', user.salt)

          expect(pbkdf).to be_eql user.pbkdf
        end
      end

    end

  end

end
