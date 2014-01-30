class PublicController < Yodatra::Base

  get '/status404' do
    status 404
  end

  get '/' do
    logger.warn 'Trying the logger in warning level'
    'Hello Home'
  end

end