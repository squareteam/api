source 'https://rubygems.org'

gem 'rake'

gem 'sinatra'
gem 'yodatra', '>= 0.2.11'

gem 'rack-rewrite'
gem 'rack-uploads', '0.2.1'

# DB adapter
gem 'mysql2', :group => :production
gem 'activerecord', '4.0.2'
gem 'sinatra-activerecord', '1.4.0'

# Cache
gem 'redis'
gem 'redis-rack'

# Omniauth
gem 'omniauth-github', '1.1.2'

group :development, :test do
  # DB adapter
  gem 'sqlite3'

  # Debug
  gem 'pry'
  gem 'pry-debugger'

  # Testing
  gem 'simplecov'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
end
