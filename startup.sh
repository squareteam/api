
redis-server &

mysqld_safe &

pushd /app
# Add a ruby wrapper
cp /app/ruby_wrapper.example /app/ruby_wrapper

. /usr/local/rvm/scripts/rvm; /usr/local/rvm/gems/ruby-2.0.0-p353@global/bin/bundle install --deployment --without development test
. /usr/local/rvm/scripts/rvm; . /app/.prod.env; RACK_ENV=production /usr/local/rvm/gems/ruby-2.0.0-p353@global/bin/bundle exec rake db:setup
popd 

# Configure&Launch NGINX
mkdir -p /etc/nginx/site-enabled
cp /app/nginx.conf.example /etc/nginx/nginx.conf
/etc/nginx/sbin/nginx

curl http://localhost/api

passenger-status

wait
