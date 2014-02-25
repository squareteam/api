require File.expand_path '../../spec_helper.rb', __FILE__

# This spec file has a complete set of data to test all the cryptic functions needed by ST
# It should be valid for both the backend and the frontend
describe 'Crypto' do

  before do
    @identifier = 'test@example.com'
    @password = 'test'
    @salt1 = '36b26d1ee22bb35e'
    @salt2 = 'a5e28ef7bcb5605b'

    @pbkdf = '46bb47131873d80ab71740876abc1e07f90c38609d570ba68d4313ef69b49460'
    @token = 'a99246bedaa6cadacaa902e190f32ec689a80a724aa4a1c198617e52460f74d1'

    @redis = Redis.new
    @redis.flushall
  end

  describe 'Token generation' do
    context 'with given inputs' do
      before do
        SALT2 = @salt2
        module SecureRandom
          def self.random_bytes(b)
            [SALT2].pack('H*')
          end
        end
      end
      it 'generates a correct token' do
        salt = Auth.generate_token(@identifier, [@pbkdf].pack('H*'))
        token = @redis.get "#{@identifier}:TOKEN"

        expect(salt.unpack('H*').first).to eq @salt2
        expect(token.unpack('H*').first).to eq @token
      end
    end
  end

  describe 'PBKDF2 generation' do
    context 'with given inputs' do
      it 'generates a correct pbkdf' do
        salt, pbkdf = Yodatra::Crypto.generate_pbkdf(@password, [@salt1].pack('H*'))
        expect(salt.unpack('H*').first).to eq @salt1
        expect(pbkdf.unpack('H*').first).to eq @pbkdf
      end
    end
  end

  describe 'Auth request' do
    context 'with given inputs' do
      before do
        allow_any_instance_of(Cache).to receive(:get).and_return([@token].pack('H*'))

        env = {
          'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/users/me',
          'QUERY_STRING' => '',
          'HTTP_ST_TIMESTAMP' => '1393369116',
          'HTTP_ST_IDENTIFIER' => @identifier,
          'HTTP_ST_HASH' => '286d86d5ca50ca07d4a2e70a9831e913df82a9c550b30fd1a33a1d061e80828f',
        }

        @request = Auth::Request.new env
      end
      it 'should be a valid request' do
        @request.valid?.should be_true
      end
    end
  end

end