source 'https://rubygems.org'

gem 'rake'

gem 'sinatra'

gem 'yodatra', :git => 'git://github.com/squareteam/yodatra', :ref => 'bd21c09f217ac3ae0667da26761aa07167dae534'

# DB adapter
gem 'mysql2', :group => :production

gem 'redis'

group :development, :test do
  # DB adapter
  gem 'sqlite3'

  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
  gem 'mocha', require: false
end


