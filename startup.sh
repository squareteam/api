#!/bin/bash

pushd /home/app
bundle install --deployment
bundle exec rake db:setup
bundle exec rake db:migrate
RACK_ENV=test bundle exec rake db:setup
RACK_ENV=test bundle exec rake db:seed
RACK_ENV=test bundle exec rake db:migrate
popd 

# Configure NGINX
mkdir -p /etc/nginx/sites-enabled
cp /home/app/dev.squareteam.io.conf /etc/nginx/sites-enabled

