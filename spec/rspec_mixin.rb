module RSpecMixin
  include Rack::Test::Methods
  def app
    Api
  end
end