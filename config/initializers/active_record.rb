require 'sinatra/activerecord'
require 'yodatra'

class Api < Yodatra::Base
  register Sinatra::ActiveRecordExtension
end
