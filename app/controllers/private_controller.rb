class PrivateController < Yodatra::Base

  before do
    content_type 'application/json'
    @cache ||= Cache.new
  end

  get '/logout' do
    identifier = request.env['REMOTE_USER']
    @cache.rm_cache "#{identifier}:SALT2"
    @cache.rm_cache "#{identifier}:TOKEN"
    'OK'.to_json
  end

  get '/private' do
    'You are authenticated and seeing a private area'.to_json
  end
end