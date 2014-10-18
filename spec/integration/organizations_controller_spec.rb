# -*- coding: utf-8 -*-
require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../../app/auth/auth.rb', __FILE__

describe OrganizationsController do

  context 'with an authenticated request' do

    before do
      @user = create :user

      authenticate_requests_as @user
    end

    describe 'GET an organization which I can access' do
      before do
        @orga_ascii = create :organization, name: 'square'
        @orga_utf8 = create :organization, name: 'test //()!%?-_éàè"'
        @orga = @orga_ascii if rand(2) == 0
        @orga = @orga || @orga_utf8
        @orga.add_admin @user
      end
      it 'responds with the data of the organization' do
        get "/organizations/#{@orga.id}"

        expect(last_response).to be_ok
        expect(last_response.body).to include(@orga.to_json(OrganizationsController.read_scope))
      end
    end
    describe 'GET an organization which I DO NOT have access' do
      before do
        @orga_ascii = create :organization, name: 'square'
        @orga_utf8 = create :organization, name: 'test //()!%?-_éàè"'
        @orga = @orga_ascii if rand(2) == 0
        @orga = @orga || @orga_utf8
      end
      it 'responds with the data of the organization' do
        get "/organizations/#{@orga.id}"

        expect(last_response.status).to be 404
      end
    end

    describe 'POST an organization' do
      context 'that does not exist' do
        before do
          Organization.destroy_all
        end
        it 'responds with the data of the organization' do
          expect {
            post '/organizations', {:name => 'swcc'}
            expect(last_response).to be_ok
          }.to change(Organization, :count).by(1)
        end
      end
      context 'that already exist' do
        before do
          create :organization, :name => 'swcc'
        end
        it 'responds with an error message' do
          expect {
            post '/organizations', {:name => 'swcc'}
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
        it 'create organization and add given users to "Admins" team' do
          u = create :user
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
          @orga = create :organization
          @user = create :user
        end
        it 'fails with a error message' do
          expect {
            delete "/organizations/#{@orga.id}/users/#{@user.id}"
          }.to change(UserRole, :count).by(0)
          expect(last_response).to_not be_ok
        end
      end
      context 'if the targeted user belongs to the organization' do
        before do
          @orga = create :organization
          @user = create :user
          @orga.add_admin @user
        end
        it 'deletes the userrole and succeeds' do
          expect {
            delete "/organizations/#{@orga.id}/users/#{@user.id}"
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
