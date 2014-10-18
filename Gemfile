source 'https://rubygems.org'

gem 'rake'

gem 'sinatra'
gem 'yodatra', '0.3.11'

gem 'rack-rewrite'
gem 'rack-parser', :require => 'rack/parser'
gem 'rack-uploads', '0.2.1'
gem 'rack-ssl', '1.4.1'

# DB adapter
gem 'mysql2'
gem 'activerecord', '4.1.5'
gem 'sinatra-activerecord', '2.0.2'

# Cache
gem 'redis'
gem 'redis-rack'

# Omniauth
gem 'omniauth-github', '1.1.2'
gem 'omniauth-behance', :github => 'popox/omniauth-behance'

# Mails
gem 'actionmailer', '4.1.5'
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
  gem 'rack-test', require: 'rack/test'
  gem 'ci_reporter_rspec'
end
