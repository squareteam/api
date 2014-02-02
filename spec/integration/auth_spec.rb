require File.expand_path '../../spec_helper.rb', __FILE__
require 'redis'
require 'openssl'
require 'base64'

describe 'Squareteam authentication' do

  before do
    @r = Redis.new
  end

  context 'when it fails the WWW-Authenticate header should explain why in case of' do
    it 'missing header' do
      get '/users'
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('St auth headers not found')
    end

    it 'wrong timestamp' do
      get '/users', {}, {'St-Timestamp' => (Time.now-3.minutes).to_s, 'St-Hash' => '*', 'St-Identifier' => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp expired')

      get '/users', {}, {'St-Timestamp' => (Time.now+3.minutes).to_s, 'St-Hash' => '*', 'St-Identifier' => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp too recent')
    end

    it 'missing token' do
      get '/users', {}, {'St-Timestamp' => (Time.now).to_s, 'St-Hash' => '*', 'St-Identifier' => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Failed to retrieve token')
    end

    it 'invalid authentication' do
      @r.set '*:TOKEN', 'my_token'
      get '/users', {}, {'St-Timestamp' => (Time.now).to_s, 'St-Hash' => '*', 'St-Identifier' => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Invalid auth')
      @r.del '*:TOKEN'
    end

  end

  context 'when all headers are present and user has already logged in and sends the correct headers' do
    before do
      @token = '\x9czBP\x07\xf7\xb04\" \x16\x84lu\xda\xaaJ\xc3\xd0\x19HTX\x1c\xe2\xfd\xee\x0e\xc4VD\xca'
      @identifier = 'test@test.fr'
    end

    it 'should succeed' do
      @r.set "#{@identifier}:TOKEN", @token
      timestamp = (Time.now).to_s
      http_url = '/users'
      data = {}

      hmac = OpenSSL::HMAC.new(@token, 'sha256')
      hmac << "GET:"
      hmac << "#{http_url}:"
      hmac << "#{timestamp}:"
      hmac << ""
      hash = hmac.digest

      get http_url, data, {'St-Timestamp' => timestamp, 'St-Hash' => hash, 'St-Identifier' => @identifier}
      last_response.should be_ok
    end
  end

end