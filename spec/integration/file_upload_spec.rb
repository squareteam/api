require File.expand_path '../../spec_helper.rb', __FILE__
require 'redis'
require 'openssl'
require 'base64'

describe 'Squareteam files upload controller' do

  before do
    @r = Redis.new
  end

  context 'when all headers are present and user has already logged in' do
    before do
      @token = 'f291e66d2306ad7984aa22bf2923b41245ecfa7b19a3c94c824583ebc197fcec'
      @identifier = 'test@test.fr'
    end

    it 'sends the file correctly to the public upload directory' do
      @r.set "#{@identifier}:TOKEN", [@token].pack('H*')
      timestamp = (Time.now).to_i.to_s
      http_url = '/files'
      data = {:file => Rack::Test::UploadedFile.new(File.expand_path('../../fixtures/test_txt.txt', __FILE__), 'text/plain') }

      hmac = OpenSSL::HMAC.new([@token].pack('H*'), 'sha256')
      hmac << "POST:"
      hmac << "#{http_url}:"
      hmac << "#{timestamp}:"
      hmac << 'file=3569a17c1f140356cb5ed0e7839396e7'
      hash = hmac.digest.unpack('H*').first

      post http_url, data, {ST_TIMESTAMP_HEADER => timestamp, ST_HASH_HEADER => hash, ST_ID_HEADER => @identifier}

      last_response.should be_ok
      Dir["#{Dir.pwd}/public/uploads/*"].should include("#{Dir.pwd}/public/uploads/test_txt.txt")
    end
  end
end
