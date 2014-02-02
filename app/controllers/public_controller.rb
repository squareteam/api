class PublicController < Yodatra::Base

  get '/status404' do
    status 404
  end

  get '/' do
    'Hello Home'
  end

end