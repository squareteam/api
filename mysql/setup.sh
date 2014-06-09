#!/usr/bin/env sh

#  MySQL DB setup if doesn't exist
if [ ! -f /var/lib/mysql/ibdata1 ]; then
  
    /usr/bin/mysql_install_db

    /usr/bin/mysqld_safe > /dev/null 2>&1 &
    /bin/sleep 3s
    
    /usr/bin/mysqladmin -u root password root
    /usr/bin/mysqladmin -u root -h localhost password root
    
    /usr/bin/killall mysqld
    /bin/sleep 3s

fi

/usr/bin/mysqld_safe > /dev/null 2>&1 &
/bin/sleep 3s

# Create Database dev DB
mysql -uroot -proot -e "CREATE DATABASE st_dev"
mysql -uroot -proot -e "CREATE DATABASE st_test"

# Create (unsafe) HelpSpot user, who can connect remotely
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON st_dev.* to 'st_dev'@'%' IDENTIFIED BY 'st_dev';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON st_test.* to 'st_dev'@'%' IDENTIFIED BY 'st_dev';"

# Shutdown MySQL
/usr/bin/mysqladmin -uroot -proot shutdown

# DEBUG only
/sbin/my_init --enable-insecure-key

#/sbin/my_init
