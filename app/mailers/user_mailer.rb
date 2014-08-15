require 'action_mailer'

class UserMailer < ActionMailer::Base

  layout "user_mailer/user_mailer"

   def account_creation(user)
      @user = user

      @title = "Welcome to Squareteam"

      mail(:to => user.email, :from => "noreply@squareteam.io", :subject => "Welcome on Squareteam !") do |format|
        format.html
      end
   end

   def forgot_password(user, token)
      @user = user
      @change_password_link = "#{Squareteam::Application::CONFIG.app_url}/#/forgot_password/change/#{token}"

      @title = "Change password request"

      mail(:to => user.email, :from => "noreply@squareteam.io", :subject => "Squareteam - Change password request") do |format|
        format.html
      end
   end
end
