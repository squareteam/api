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
=end

require File.expand_path '../cache', __FILE__

class Auth < Rack::Auth::AbstractHandler

  AUTH_TIMEOUT = ENV['AUTH_TIMEOUT'] || (3600)

  class << self
    def cache
      @cache ||= Cache.new
    end

    def login(user)
      return nil if user.nil?

      cached_salt2 = cache.get "#{user.email}:SALT2"
      cached_oauth = cache.get "#{user.email}:OAUTH"
      keep_going = true
      if user.provider != 'squareteam'
        keep_going = cached_oauth.blank? ? false : user.oauth_login(cached_oauth)
      end

      return nil unless keep_going

      if cached_salt2.nil?
        salt2 = SecureRandom.random_bytes(8)

        hmac = OpenSSL::HMAC.new(salt2+user.pbkdf, 'sha256')
        hmac << "#{user.email}"
        token = hmac.digest

        cache.set("#{user.email}:SALT2", AUTH_TIMEOUT, salt2)
        cache.set("#{user.email}:TOKEN", AUTH_TIMEOUT, token)
      else
        salt2 = cached_salt2

        cache.expire("#{user.email}:SALT2", AUTH_TIMEOUT)
        cache.expire("#{user.email}:TOKEN", AUTH_TIMEOUT)
      end

      salt2
    end
  end

  def call(env)

    auth = Request.new(env)

    return api_unauthorized('St auth headers not found') unless auth.provided?
    return api_unauthorized(auth.invalid_timestamp) unless auth.invalid_timestamp.nil?
    return api_unauthorized('Failed to retrieve token') if auth.token.nil?
    return api_unauthorized('Invalid auth') unless auth.valid?

    env['REMOTE_USER'] = auth.identifier
    @app.call(env)
  end

  def api_unauthorized(message)
    status, headers, body = unauthorized(message)
    headers['Content-Type'] = 'application/json'
    body << [Errors::UNAUTHORIZED].to_json
    [status, headers, body]
  end

  class Request < Rack::Auth::AbstractRequest


    # Fast, without infinite loop checking toString helper
    def generate_blob(data)
      def encodeUriQuery(val)
        Rack::Utils.escape(val).gsub(/%40/, '@').
                    gsub(/%3A/, ':').
                    gsub(/%24/, '$').
                    gsub(/%2C/, ',').
                    gsub(/%20/, '+')
      end

      def dirty_stringify(value, key=nil)
        buffer = []
        if value.is_a?(Hash)
          value.sort.each do |k,v|
            buffer << dirty_stringify(v, !key.nil? ? [key,'{', k ,'}'].join('') : k)
          end
          return buffer.join '&'
        elsif value.is_a?(Array)
          value.each do |v|
            buffer << dirty_stringify(v, [key,'[]'].join(''))
          end
          buffer.join '&'
        else
          [key, '=', encodeUriQuery(value)].join ''
        end
      end

      dirty_stringify data
    end


    def valid?
      require 'openssl'

      blob = request.params.nil? ? '' : generate_blob(request.params)

      hmac = OpenSSL::HMAC.new(token, 'sha256')
      hmac << "#{request.request_method}:"
      hmac << "#{request.path}:"
      hmac << "#{timestamp}:"
      hmac << "#{blob}"
      return false if hmac.digest.unpack('H*').first != hash

      cache.expire "#{identifier}:SALT2", Auth::AUTH_TIMEOUT
      cache.expire "#{identifier}:TOKEN", Auth::AUTH_TIMEOUT
      true
    end

    def identifier
      @env[id_key]
    end

    def provided?
      !timestamp_key.nil? && !hash_key.nil? && !id_key.nil?
    end

    def invalid_timestamp
      return 'Timestamp expired' if timestamp < (Time.now-2.minutes).to_i.to_s
      return 'Timestamp too recent' if timestamp > (Time.now+2.minutes).to_i.to_s
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

    TIMESTAMP_KEY = %w(HTTP_ST_TIMESTAMP)
    HASH_KEY = %w(HTTP_ST_HASH)
    ID_KEY = %w(HTTP_ST_IDENTIFIER)

    private

    def cache
      @cache ||= Cache.new
    end

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