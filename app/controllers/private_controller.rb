class PrivateController < Yodatra::Base

  before do
    content_type 'application/json'
  end

  get '/private' do
    ['You are authenticated and seeing a private area']
  end
end