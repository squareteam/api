if [ ! -f /var/lib/mysql/ibdata1 ]; then
	
  mysql_install_db

  mysqld_safe &
  sleep 10s

  echo "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql
  echo "DROP USER 'root'@'localhost';" | mysql
  echo "DROP USER 'root'@'127.0.0.1';" | mysql
  echo "DROP USER 'root'@'::1';" | mysql

  killall mysqld
  sleep 10s

fi

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
