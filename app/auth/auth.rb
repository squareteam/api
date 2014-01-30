=begin
	Authentification functions.

	Register:

	- Client send : identifier and password
	- Server gen SALT1
	- Server store : identifier + SALT1 + PBKDF2_SHA256(SALT1, password)

	Connection :

	- Client send : identifier
	- Serven gen SALT2
	- Server send : SALT1 and SALT2
	- Client compute : TOKEN = HMAC_SHA256(SALT2+PBKDF2_SHA256(SALT1, password), identifier) and store it (cookie or memory).
	- Serve compute : TOKEN = HMAC_SHA256(SALT2+PBKDF2_SHA256(SALT1, password), identifier) and store it in cache (with timeout).

	Request authenticated :

	- Client send : identifier + timestamp + data + HMAC_SHA256(TOKEN, HTTP_method+":"+URL+":"+timestamp+":"+data)
	- Server check the timestamp and the hmac.

	Data must be encoded as url parameter (key1=arg1&key2=arg2&key3=arg3...) sorted by key.

	Client must send 3 fields in the HTTP headers :

		- St-Identifier : the identifier of the user
		- St-Timestamp  : the timestamp
		- St-Hash       : the compute hash
=end
class Auth < AbstractHandler

  def call(env)

    return [ 401, {}, '']

    auth = Basic::Request.new(env)

    return unauthorized unless auth.provided?

    return bad_request unless auth.basic?

    if valid?(auth)
      env['REMOTE_USER'] = auth.username

      return @app.call(env)
    end

    unauthorized
  end


  private

  def challenge
    'Basic realm="%s"' % realm
  end

  def valid?(auth)
    @authenticator.call(*auth.credentials)
  end

  class Request < Auth::AbstractRequest
    def basic?
      !parts.first.nil? && "basic" == scheme
    end

    def credentials
      @credentials ||= params.unpack("m*").first.split(/:/, 2)
    end

    def username
      credentials.first
    end
  end

end
      package auth

      import (
                 "crypto/hmac"
      "crypto/sha256"
      "encoding/hex"
      "errors"
      "log"
      "net/http"
      "os"
      "squareteam/api"
      "squareteam/api/models"
      "strconv"
      "time"
      )

      var (
              authtimeout  = os.Getenv("AUTHTIMEOUT")
      cachetimeout = os.Getenv("CACHETIMEOUT")
      )

      // CheckAuth parse given http.Request and return nil if authentification
      // is correct.
                func CheckAuth(r *http.Request) error {
        timestamp, err := strconv.ParseInt(r.Header.Get("St-Timestamp"), 10, 64)
        if err != nil {
            return err
        }
        if timestamp < time.Now().Add(-time.Minute*2).Unix() {
          return errors.New("Timestamp expired")
        }
          if timestamp > time.Now().Add(time.Minute*2).Unix() {
            return errors.New("Timestamp too new")
          }
            identifier := r.Header.Get("St-Identifier")
            token, err := api.Uncache(identifier + ":TOKEN")
            if err != nil {
                return err
            }
            if token == nil {
                return errors.New("Fail to uncache token")
            }
            ctx := hmac.New(sha256.New, token.([]byte))
            // HTTP Method
            _, err = ctx.Write([]byte(r.Method + ":"))
            if err != nil {
                return err
            }
            // HTTP URL
            _, err = ctx.Write([]byte(r.URL.Path + ":"))
            if err != nil {
                return err
            }
            // Timestamp
            _, err = ctx.Write([]byte(r.Header.Get("St-Timestamp") + ":"))
            if err != nil {
                return err
            }
            // Data
            r.ParseForm()
            _, err = ctx.Write([]byte(r.Form.Encode()))
            if err != nil {
                return err
            }
            hash := ctx.Sum(nil)
            hash2, err := hex.DecodeString(r.Header.Get("St-Hash"))
            if err != nil {
                return err
            }
            if !hmac.Equal(hash2, hash) {
              return errors.New("Bad HMAC")
            }
              api.Expire(identifier+":SALT2", authtimeout)
              api.Expire(identifier+":TOKEN", authtimeout)
              return nil
              }

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

              end

              end
  end
end