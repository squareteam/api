require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Users controller' do

  before do
    allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
    allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
    allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
    allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
  end

  describe 'registration process' do
    context 'when the email has already been taken' do
      before do
        @email_already_taken = 'test@test.fr'
        post '/register', {:password => 'test', :identifier => @email_already_taken}
      end

      it 'responds with a 400 and an explicit error message' do
        post '/register', {:password => 'test', :identifier => @email_already_taken}

        last_response.should_not be_ok
        expect(last_response.body).to match(/Email has already been taken/)
      end
    end

    context 'when everything is fine' do
      it 'creates a user in the db' do
        expect {
          post('/register', {:password => 'test', :identifier => 'test2@test.fr'})
        }.to change(User, :count).by(1)

        last_response.should be_ok
      end
    end
  end

  after do
    User.destroy_all
  end

end
