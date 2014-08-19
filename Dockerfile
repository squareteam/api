# DOCKER-VERSION 0.10.0
FROM swcc/passenger-chef-mysql:latest
MAINTAINER Paul B. "paul+st@bonaud.fr"

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use baseimage-docker's init process.
CMD /sbin/my_init --enable-insecure-key
