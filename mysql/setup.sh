#!/usr/bin/env sh

#  MySQL DB setup if doesn't exist
if [ ! -f /var/lib/mysql/ibdata1 ]; then
    /usr/bin/mysql_install_db
fi

# Reset root password to root
/usr/bin/mysqld_safe --skip-grant-tables > /dev/null 2>&1 &
/bin/sleep 2s
mysql -e "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';flush privileges;" -u root mysql


# # Create Database dev DB
if [ ! -f /var/lib/mysql/st_dev ]; then
    mysql -uroot -proot -e "CREATE DATABASE st_dev"
fi
if [ ! -f /var/lib/mysql/st_test ]; then
    mysql -uroot -proot -e "CREATE DATABASE st_test"
fi

# # Create (unsafe) HelpSpot user, who can connect remotely
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON st_dev.* to 'st_dev'@'%' IDENTIFIED BY 'st_dev';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON st_test.* to 'st_dev'@'%' IDENTIFIED BY 'st_dev';"

# # Shutdown MySQL
/usr/bin/mysqladmin -uroot -proot shutdown

# # DEBUG only
# #/sbin/my_init --enable-insecure-key

/sbin/my_init
