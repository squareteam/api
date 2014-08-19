# -*- coding: utf-8 -*-
require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe 'Organizations controller' do

  context 'with an authenticated request' do

    before do
      Team.destroy_all
      Organization.destroy_all

      @user = User.last || User.create(:email => 'test@test.fr', :pbkdf => 'fff', :salt => 'fff')

      allow_any_instance_of(Auth::Request).to receive(:provided?).and_return(true)
      allow_any_instance_of(Auth::Request).to receive(:invalid_timestamp).and_return(nil)
      allow_any_instance_of(Auth::Request).to receive(:token).and_return('fake')
      allow_any_instance_of(Auth::Request).to receive(:valid?).and_return(true)
    end

    describe 'GET an organization' do
      before do
        @orga_ascii = Organization.create name: 'squareteam'
        @orga_utf8 = Organization.create name: 'test //()!%?-_éàè"'
        @orga = @orga_ascii if rand(2) == 0
        @orga = @orga || @orga_utf8
      end
      it 'responds with the data of the organization' do
        get "/organization/#{@orga.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include(@orga.to_json(OrganizationsController.read_scope))
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
            expect(last_response).to be_ok
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
            expect(last_response).to_not be_ok
            expect(last_response.body).to match /api.already_taken/
          }.not_to change(Organization, :count)
        end
      end
    end

    describe 'POST /organizations/with_admins' do
      context 'without admins_ids params' do
        before do
          Organization.destroy_all
        end
        it 'responds "400 Bad Request" if no admins given' do
          expect {
            post '/organizations/with_admins', {:name => 'swcc'}
            expect(last_response).to_not be_ok
          }.not_to change(Organization, :count)
        end
      end
      context 'create organization and add given users to "Admins" team' do
        before do
          Organization.destroy_all
          UserRole.destroy_all
        end
        it 'create organization and add given users to "Admins" team' do
          u = User.easy_new(name: 'test', email: 'test@example.com', password: 'yo')
          u.save
          expect {
            post '/organizations/with_admins', {:name => 'swcc', :admins_ids => [u.id]}
            expect(last_response).to be_ok
          }.to change(Team, :count).by(1)
          expect(Organization.count).to equal(1)
          expect(UserRole.count).to equal(1)
        end
      end
    end

    describe 'Remove a User from an organization' do
      context 'if the targeted user doesn\'t belong to the organization' do
        before do
          Organization.destroy_all
          User.destroy_all
          @orga = Organization.create(name: 'test')
          @user = User.easy_create(name: 'jo',password:'jo',email:'jo@com.fr')
        end
        it 'fails with a error message' do
          expect {
            delete "/organization/#{@orga.id}/user/#{@user.id}"
          }.to change(UserRole, :count).by(0)
          expect(last_response).to_not be_ok
        end
      end
      context 'if the targeted user belongs to the organization' do
        before do
          Organization.destroy_all
          User.destroy_all
          @orga = Organization.create(name: 'test')
          @user = User.easy_create(name: 'jo',password:'jo',email:'jo@com.fr')
          @orga.add_admin @user
        end
        it 'deletes the userrole and succeeds' do
          expect {
            delete "/organization/#{@orga.id}/user/#{@user.id}"
          }.to change(UserRole, :count).by(-1)
          expect(last_response).to be_ok
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
    #       expect(last_response).to be_ok
    #     }.to change(Organization, :count).by(1)
    #     expect { Organization.last.users.to include @user }
    #   end
    # end

  end

end
