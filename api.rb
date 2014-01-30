require 'yodatra/base'
require 'yodatra/logger'

class Api < Yodatra::Base
  enable :sessions
  use Yodatra::Logger

  use PublicController

  use Auth

  use UsersController

end
