source 'https://rubygems.org'

gem 'rake'

gem 'sinatra'
gem 'rack-rewrite'

gem 'yodatra', :branch => 'master', :git => 'https://github.com/squareteam/yodatra'

# DB adapter
gem 'mysql2', :group => :production

gem 'redis'

group :development, :test do
  # DB adapter
  gem 'sqlite3'

  gem 'simplecov'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
end


