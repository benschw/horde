FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
RUN apt-get clean && apt-get update
RUN apt-get install locales
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8



RUN apt-get install -y mysql-client-core-5.7 mysql-server-core-5.7 mysql-server-5.7 mysql-client-5.7

# create admin user (root is stuck on localhost)
RUN /etc/init.d/mysql start & \
	sleep 10s &&\
	echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

# allow non localhost connections
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

ADD ca.pem /etc/mysql/cacert.pem
ADD server-cert.pem /etc/mysql/server-cert.pem
ADD server-key.pem /etc/mysql/server-key.pem

RUN sed -i -e"s/^#\s*ssl-ca/ssl-ca/" /etc/mysql/mysql.conf.d/mysqld.cnf
RUN sed -i -e"s/^#\s*ssl-cert/ssl-cert/" /etc/mysql/mysql.conf.d/mysqld.cnf
RUN sed -i -e"s/^#\s*ssl-key/ssl-key/" /etc/mysql/mysql.conf.d/mysqld.cnf

RUN /etc/init.d/mysql restart


EXPOSE 3306

CMD ["/usr/bin/mysqld_safe"]

