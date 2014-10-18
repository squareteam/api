require File.expand_path '../../spec_helper.rb', __FILE__
require 'redis'
require 'openssl'
require 'base64'

describe 'Squareteam authentication' do

  before do
    @r = Redis.new Squareteam::Application::CONFIG.redis
  end

  context 'when it fails the WWW-Authenticate header should explain why in case of' do
    it 'missing header' do
      get '/users'
      expect(last_response).to_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('St auth headers not found')
    end

    it 'wrong timestamp' do
      get '/users', {}, {'HTTP_ST_TIMESTAMP' => (Time.now-3.minutes).to_i.to_s, 'HTTP_ST_HASH' => '*', 'HTTP_ST_IDENTIFIER' => '*'}
      expect(last_response).to_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp expired')

      get '/users', {}, {'HTTP_ST_TIMESTAMP' => (Time.now+3.minutes).to_i.to_s, 'HTTP_ST_HASH' => '*', 'HTTP_ST_IDENTIFIER' => '*'}
      expect(last_response).to_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp too recent')
    end

    it 'missing token' do
      @r.del '*:TOKEN'
      get '/users', {}, {'HTTP_ST_TIMESTAMP' => (Time.now).to_i.to_s, 'HTTP_ST_HASH' => '*', 'HTTP_ST_IDENTIFIER' => '*'}
      expect(last_response).to_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Failed to retrieve token')
    end

    it 'invalid authentication' do
      @r.set '*:TOKEN', 'my_token'
      get '/users', {}, {'HTTP_ST_TIMESTAMP' => (Time.now).to_i.to_s, 'HTTP_ST_HASH' => '*', 'HTTP_ST_IDENTIFIER' => '*'}
      expect(last_response).to_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Invalid auth')
      @r.del '*:TOKEN'
    end

  end

  context 'when all headers are present and user has already logged in' do
    before do
      @token = 'f291e66d2306ad7984aa22bf2923b41245ecfa7b19a3c94c824583ebc197fcec'
      @identifier = 'test@test.fr'
    end

    context 'GETting a private route' do
      it 'should succeed' do
        @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
        timestamp = (Time.now).to_i.to_s
        http_url = '/private'
        data = {}

        hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
        hmac << "GET:"
        hmac << "#{http_url}:"
        hmac << "#{timestamp}:"
        hmac << ""
        hash = hmac.digest.unpack('H*').first

        get http_url, data, {'HTTP_ST_TIMESTAMP' => timestamp, 'HTTP_ST_HASH' => hash, 'HTTP_ST_IDENTIFIER' => @identifier}

        expect(last_response).to be_ok
      end
    end

    context 'POSTing a private route' do
      it 'should succeed' do
        @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
        timestamp = (Time.now).to_i.to_s
        http_url = '/organizations'
        data = {:name => 'st'}

        hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
        hmac << "POST:"
        hmac << "#{http_url}:"
        hmac << "#{timestamp}:"
        hmac << "name=st"
        hash = hmac.digest.unpack('H*').first

        post http_url, data, {'HTTP_ST_TIMESTAMP' => timestamp, 'HTTP_ST_HASH' => hash, 'HTTP_ST_IDENTIFIER' => @identifier}

        expect(last_response).to be_ok
      end
    end

    context 'GETting a non existent route' do
      it 'fails with a msg' do
        @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
        timestamp = (Time.now).to_i.to_s
        http_url = '/nothing/to/do/here'
        data = {}

        hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
        hmac << "GET:"
        hmac << "#{http_url}:"
        hmac << "#{timestamp}:"
        hmac << ""
        hash = hmac.digest.unpack('H*').first

        get http_url, data, {'HTTP_ST_TIMESTAMP' => timestamp, 'HTTP_ST_HASH' => hash, 'HTTP_ST_IDENTIFIER' => @identifier}

        expect(last_response.status).to be(400)
        expect(last_response.body).to match(/api.no_route/)
      end
    end

    context 'Logout' do
      it 'should be possible and remove tokens from the cache' do
        @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
        # Timestamp (/!\ Unix time .to_i!)
        timestamp = (Time.now).to_i.to_s
        http_url = '/logout'
        data = {}

        hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
        hmac << "GET:"
        hmac << "#{http_url}:"
        hmac << "#{timestamp}:"
        hmac << ""
        hash = hmac.digest.unpack('H*').first

        get http_url, data, {'HTTP_ST_TIMESTAMP' => timestamp, 'HTTP_ST_HASH' => hash, 'HTTP_ST_IDENTIFIER' => @identifier}

        expect(last_response).to be_ok
        expect(@r.get "#{@identifier}:TOKEN").to be_nil
        expect(@r.get "#{@identifier}:SALT2").to be_nil
      end
    end

  end

end
