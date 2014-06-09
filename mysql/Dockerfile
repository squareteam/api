# DOCKER-VERSION 0.10.0
FROM swcc/docker-mysql:latest
MAINTAINER Paul B. "paul+st@bonaud.fr"

ADD ./setup.sh /etc/mysql/mysql_setup.sh
RUN chmod +x   /etc/mysql/mysql_setup.sh

CMD /etc/mysql/mysql_setup.sh
