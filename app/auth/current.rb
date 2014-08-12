# Add helpers to our sinatra app for auth
module Sinatra
  module Helpers
    def current_user
      if current_user_identifier
        User.find_by_email(current_user_identifier)
      else
        nil
      end
    end

    def current_user_identifier
      request.env['REMOTE_USER']
    end

    def logged_in?
      !!current_user_identifier
    end
  end
end
