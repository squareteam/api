=begin
Authentification functions.

	Register:
	- Client sends identifier and password
	- Server gen SALT1
	- Server store : identifier, SALT1 and PBKDF2_SHA256(SALT1, password)

	Connection:
	- Client sends identifier
	- Server gen SALT2
	- Server sends SALT1 and SALT2
	- Client computes TOKEN = HMAC_SHA256(SALT2+PBKDF2_SHA256(SALT1, password), identifier) and stores it (cookie or memory).
	- Serve computes TOKEN = HMAC_SHA256(SALT2+PBKDF2_SHA256(SALT1, password), identifier) and stores it in cache (with timeout).

	Authenticated request:
	- Client sends identifier, timestamp, data and HMAC_SHA256(TOKEN, HTTP_method+":"+URL+":"+timestamp+":"+data)
	- Server check the timestamp and the hmac.

	  Data must be encoded as url parameter (key1=arg1&key2=arg2&key3=arg3...) sorted by key.

    Client must send 3 fields in the HTTP headers :

      - St-Identifier : the identifier of the user
      - St-Timestamp  : the timestamp
      - St-Hash       : the compute hash

  TODO:
    // Generate token by computing identifier with salt+hash using HMAC_SHA256
    func GenToken(identifier string) ([]byte, error) {
        tsalt2, err := api.Uncache(identifier + ":SALT2")
    var salt2 []byte
    if err != nil || tsalt2 == nil {
        salt2 = api.Rand(8)
    if salt2 == nil {
        log.Println("GenToken: Fail to gen random salt")
    return nil, errors.New("GenToken: fail Rand salt")
    }
    user, err := models.GetUser(identifier)
    if err != nil {
        return nil, err
    }

    ctx := hmac.New(sha256.New, append(salt2, user.PBKDF...))
    ctx.Write([]byte(identifier))
    token := ctx.Sum(nil)

    api.Cache(identifier+":SALT2", authtimeout, salt2)
    api.Cache(identifier+":TOKEN", authtimeout, token)
    } else {
        salt2 = tsalt2.([]byte)
    api.Expire(identifier+":SALT2", authtimeout)
    api.Expire(identifier+":TOKEN", authtimeout)
    }
    return salt2, nil
    }

    // Use to logout
    func DeleteToken(identifier string) {
      api.RmCache(identifier + ":SALT2")
      api.RmCache(identifier + ":TOKEN")
    }

    // Generate PBKDF2_SHA256
    func GenPBKDF(password, salt []byte) []byte {
      _, hash := api.PBKDF2_SHA256(password, salt)
      return hash
    }
=end

require File.expand_path '../cache', __FILE__

class Auth < Rack::Auth::AbstractHandler

  def call(env)

    auth = Request.new(env)

    return unauthorized('St auth headers not found') unless auth.provided?
    return unauthorized(auth.invalid_timestamp) unless auth.invalid_timestamp.nil?
    return unauthorized('Failed to retrieve token') if auth.token.nil?
    return unauthorized('Invalid auth') unless auth.valid?

    env['REMOTE_USER'] = auth.identifier
    @app.call(env)
  end

  class Request < Rack::Auth::AbstractRequest

    def valid?
      require 'openssl'
      require 'base64'

      hmac = OpenSSL::HMAC.new(token, 'sha256')
      hmac << "#{http_method}:"
      hmac << "#{http_url}:"
      hmac << "#{timestamp}:"
      hmac << "#{data}"
      return false if hmac.digest != hash

      cache.expire "#{identifier}:SALT2", AUTH_TIMEOUT
      cache.expire "#{identifier}:TOKEN", AUTH_TIMEOUT
      true
    end

    def identifier
      @env[id_key]
    end

    def provided?
      !timestamp_key.nil? && !hash_key.nil? && !id_key.nil?
    end

    def invalid_timestamp
      return 'Timestamp expired' if timestamp < (Time.now-2.minutes).to_s
      return 'Timestamp too recent' if timestamp > (Time.now+2.minutes).to_s
      nil
    end

    def hash
      @env[hash_key]
    end

    def token
      cache.get("#{identifier}:TOKEN")
    end

    def timestamp
      @env[timestamp_key]
    end

    def http_method
      @env['REQUEST_METHOD']
    end

    def http_url
      @env['PATH_INFO']
    end

    def data
      @env['QUERY_STRING']
    end

    private

    def cache
      @cache ||= Cache.new
    end

    TIMESTAMP_KEY = %w(St-Timestamp)
    HASH_KEY = %w(St-Hash)
    ID_KEY = %w(St-Identifier)

    AUTH_TIMEOUT = ENV['AUTHTIMEOUT'] || (3600)

    def timestamp_key
      @timestamp_key ||= TIMESTAMP_KEY.detect { |key| @env.has_key?(key) }
    end
    def hash_key
      @hash_key ||= HASH_KEY.detect { |key| @env.has_key?(key) }
    end
    def id_key
      @id_key ||= ID_KEY.detect { |key| @env.has_key?(key) }
    end

  end

end