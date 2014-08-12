require 'rack/uploads'

class PrivateController < Yodatra::Base

  before do
    content_type 'application/json'
    @cache ||= Cache.new
  end

  get '/logout' do
    identifier = current_user_identifier
    @cache.rm_cache "#{identifier}:SALT2"
    @cache.rm_cache "#{identifier}:TOKEN"
    'OK'.to_json
  end

  get '/private' do
    'You are authenticated and seeing a private area'.to_json
  end

  use Rack::Uploads

  post '/files' do
    @env['rack.uploads'].each do |upload|
      upload.mv("#{Dir.pwd}/public/uploads/#{upload.filename}")
    end if @env['rack.uploads']
    'ok'.to_json
  end
end
