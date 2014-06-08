#!/bin/bash

pushd /home/app
bundle install --deployment --without test
bundle exec rake db:setup
bundle exec rake db:migrate
popd 

# Configure NGINX
mkdir -p /etc/nginx/sites-enabled
cp /home/app/dev.clicrdv.io.conf /etc/nginx/sites-enabled

