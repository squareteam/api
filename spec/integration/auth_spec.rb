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
      get '/users', {}, {ST_TIMESTAMP_HEADER => (Time.now-3.minutes).to_s, ST_HASH_HEADER => '*', ST_ID_HEADER => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp expired')

      get '/users', {}, {ST_TIMESTAMP_HEADER => (Time.now+3.minutes).to_s, ST_HASH_HEADER => '*', ST_ID_HEADER => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Timestamp too recent')
    end

    it 'missing token' do
      @r.del '*:TOKEN'
      get '/users', {}, {ST_TIMESTAMP_HEADER => (Time.now).to_s, ST_HASH_HEADER => '*', ST_ID_HEADER => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Failed to retrieve token')
    end

    it 'invalid authentication' do
      @r.set '*:TOKEN', 'my_token'
      get '/users', {}, {ST_TIMESTAMP_HEADER => (Time.now).to_s, ST_HASH_HEADER => '*', ST_ID_HEADER => '*'}
      last_response.should_not be_ok
      expect(last_response.headers['WWW-Authenticate']).to eq('Invalid auth')
      @r.del '*:TOKEN'
    end

  end

  context 'when all headers are present and user has already logged in and sends the correct headers' do
    before do
      @token = 'f291e66d2306ad7984aa22bf2923b41245ecfa7b19a3c94c824583ebc197fcec'
      @identifier = 'test@test.fr'
    end

    it 'should succeed' do
      @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
      timestamp = (Time.now).to_s
      http_url = '/private'
      data = {}

      hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
      hmac << "GET:"
      hmac << "#{http_url}:"
      hmac << "#{timestamp}:"
      hmac << ""
      hash = hmac.digest.unpack('H*').first

      get http_url, data, {ST_TIMESTAMP_HEADER => timestamp, ST_HASH_HEADER => hash, ST_ID_HEADER => @identifier}

      last_response.should be_ok
    end
  end

end