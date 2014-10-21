#!/bin/bash


# ##############################
# Application bundling/configure
pushd /home/app
# Install Nokogiri with system libraries (it will fail otherwise)
test -d /usr/include/libxml2 || apt-get update && apt-get install -y libxml2-dev && apt-get clean
bundle config --local build.nokogiri --use-system-libraries --with-xml2-include=/usr/include/libxml2
apt-get clean
# END Install Nokogiri
bundle install --deployment
bundle exec rake db:setup
bundle exec rake db:migrate
RACK_ENV=test bundle exec rake db:setup
RACK_ENV=test bundle exec rake db:seed
RACK_ENV=test bundle exec rake db:migrate
popd
# ##############################


# ##############################
# Configure NGINX
mkdir -p /etc/nginx/ssl
mkdir -p /etc/nginx/sites-enabled
cp /home/app/nginx/ssl/dev.squareteam.io.key /etc/nginx/ssl
cp /home/app/nginx/ssl/dev.squareteam.io.crt /etc/nginx/ssl
cp /home/app/nginx/squareteam.io.conf /etc/nginx/sites-enabled
# ##############################
