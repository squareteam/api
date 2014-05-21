# DOCKER-VERSION 0.10.0
FROM swcc/chef:12.04
MAINTAINER Paul B. "paul+st@bonaud.fr"

# Update packages
RUN apt-get update -y

# Ugly hack for redisio cookbook
RUN apt-get install sudo

# Ugly hack for Ubuntu. See https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

# Launch Chef provisioning
ADD ./chef /chef
RUN cd /chef && /opt/chef/embedded/bin/berks vendor /chef/cookbooks
RUN chef-solo -c /chef/solo.rb -j /chef/solo.json

# Install mysql-server because mysql cookbook is sh*t
RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password root | debconf-set-selections
RUN apt-get install -y mysql-server

# Hack to create a privilege separation directory for sshd
RUN mkdir /var/run/sshd
RUN echo "root:toor" | chpasswd # need a password for ssh

# Hack
RUN adduser www-data rvm

# Prepare for Squareteam app
RUN mkdir -p /app

WORKDIR /app
ENTRYPOINT /bin/bash --login "startup.sh"
