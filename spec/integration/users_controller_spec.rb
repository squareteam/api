require File.expand_path '../../spec_helper.rb', __FILE__
require 'mocha/setup'
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Users controller' do

  before do
    Auth::Request.any_instance.stubs(:provided?).returns(true)
    Auth::Request.any_instance.stubs(:invalid_timestamp).returns(nil)
    Auth::Request.any_instance.stubs(:token).returns('fake')
    Auth::Request.any_instance.stubs(:valid?).returns(true)
  end

  describe 'registration process' do
    context 'when the email has already been taken' do
      before do
        @email_already_taken = 'test@test.fr'
        post '/register', {:name => 'test', :email => @email_already_taken}
      end

      it 'responds with a 400 and an explicit error message' do
        post '/register', {:name => 'test', :email => @email_already_taken}

        last_response.should_not be_ok
        expect(last_response.body).to match(/Email has already been taken/)
      end
    end

    context 'when everything is fine' do
      it 'creates a user in the db' do
        expect {
          post('/register', {:name => 'test', :email => 'test2@test.fr'})
        }.to change(User, :count).by(1)

        last_response.should be_ok
      end
    end
  end

  after do
    User.destroy_all
  end

end