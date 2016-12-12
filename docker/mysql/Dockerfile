FROM ubuntu:14.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y mysql-server mysql-client

# create admin user (root is stuck on localhost)
RUN /usr/sbin/mysqld & \
	sleep 10s &&\
	echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

# allow non localhost connections
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf


EXPOSE 3306

CMD ["/usr/bin/mysqld_safe"]

