#!/bin/bash


# ##############################
# ENV setup
# warning: these are insecure dev app key/secret
export GITHUB_APP_SECRET=841d9089d13e7dd45a01d00b7616ecf8bc179ef4
export GITHUB_APP_KEY=9a79820e47b0f83cbfa1
# ##############################


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
mkdir -p /etc/nginx/sites-enabled
cp /home/app/dev.squareteam.io.conf /etc/nginx/sites-enabled
# ##############################
