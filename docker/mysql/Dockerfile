FROM mysql:5.7


# create admin user (root is stuck on localhost)

ENV MYSQL_ROOT_PASSWORD=
ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes

RUN docker-entrypoint.sh mysqld & \
	sleep 30s &&\
	echo ADDING ADMIN USER &&\
	echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql -uroot

# allow non localhost connections
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf


#EXPOSE 3306

#CMD ["/usr/bin/mysqld_safe"]

