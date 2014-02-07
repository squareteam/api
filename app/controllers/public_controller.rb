require File.expand_path 'app/auth/auth.rb'

class PublicController < Yodatra::Base

  API_LOGIN_FAIL = 'Login fail'

  get '/status404' do
    status 404
  end

  get '/' do
    'Hello Home'
  end

  put '/login' do
    @one = User.find_by_email(params[:identifier])

    if @one.nil?
      status 400
      [API_LOGIN_FAIL].to_json
    else
      salt2 = Auth.generate_token(@one.email, @one.pbkdf)
      {:salt1 => @one.salt, :salt2 => salt2}.to_json
    end

  end

end