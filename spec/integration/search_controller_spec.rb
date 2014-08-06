require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Search controller' do
  context 'when authenticated' do
    before do
      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    end

    describe 'User search' do
      describe 'Simple term search' do
        before do
          (1..10).each do |i|
            User.easy_create(name: "John doe#{i}", password: 'test', email:"john#{i}@swcc.com")
          end
        end
        it 'works' do
          get '/search/users/john4'

          last_response.should be_ok
          parsed_body = JSON.parse last_response.body
          expect(parsed_body['data'].first).to eq(User.find_by_email('john4@swcc.com').as_json(UsersController.read_scope))
        end
      end

      describe 'Search nested on an Organization' do
        before do
          User.destroy_all
          Organization.destroy_all
          u = User.easy_create(name: 'John doe', password: 'test', email:'john@swcc.com')
          u2 = User.easy_create(name: 'Marie doe', password: 'test', email:'mdoe@swcc.com')
          o = Organization.create(name: 'example')
          o.add_admin u.id
          o.add_admin u2.id
        end
        it 'works' do
          get '/search/users/organization:example+marie'

          last_response.should be_ok
          parsed_body = JSON.parse last_response.body
          expect(parsed_body['data'].first).to eq(User.find_by_email('mdoe@swcc.com').as_json(UsersController.read_scope))
        end
      end
    end
  end
end
