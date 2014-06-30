require 'action_mailer'

class UserMailer < ActionMailer::Base

   def account_creation(user)
      @user = user

      mail(:to => user.email, :from => "noreply@squareteam.io", :subject => "Welcome on Squareteam !") do |format|
        format.html
      end
   end

   def forgot_password(user, token)
      @user = user
      @change_password_link = "#{Squareteam::Application::CONFIG.app_url}/#/forgotPassword/change/#{token}"

      mail(:to => user.email, :from => "noreply@squareteam.io", :subject => "Squareteam - Change password request") do |format|
        format.html
      end
   end
end
