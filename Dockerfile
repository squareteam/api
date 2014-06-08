# DOCKER-VERSION 0.10.0
FROM swcc/passenger-chef-mysql:latest
MAINTAINER Paul B. "paul+st@bonaud.fr"

# Use baseimage-docker's init process.
CMD /sbin/my_init --enable-insecure-key
