source 'https://rubygems.org'

gem 'rake'

gem 'sinatra'
gem 'yodatra', '0.3.12'

gem 'rack-rewrite'
gem 'rack-parser', :require => 'rack/parser'
gem 'rack-uploads'
gem 'rack-ssl'

# DB adapter
gem 'mysql2'
gem 'activerecord', '4.1.8'
gem 'sinatra-activerecord'

# Cache
gem 'redis'
gem 'redis-rack'

# Omniauth
gem 'omniauth-github'
gem 'omniauth-behance', :github => 'popox/omniauth-behance'

# Mails
gem 'actionmailer', '4.1.8'
gem 'inline-style', '0.5.1'

# Monitoring
gem 'newrelic_rpm'

gem 'rspec'
group :development do
  # Debug
  gem 'pry'
  #gem 'pry-debugger'
  gem 'rubocop'
  gem 'rubycritic'
end

group :test do
  # Testing
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'simplecov'
  gem 'coveralls'
  gem 'rack-test', require: 'rack/test'
  gem 'ci_reporter_rspec'
end
