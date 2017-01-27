FROM ubuntu:14.04

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8


ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y \
	php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl \
	php5-gd php5-mcrypt php5-intl php5-imap php5-tidy php5-memcache
RUN apt-get install -y \
	nginx \
	memcached \
	mysql-client \
	supervisor
RUN php5enmod mcrypt

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini

RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/www

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
 
ADD nginx-site   /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stdout /var/log/nginx/error.log

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD phinx.php /etc/phinx.php
ADD migrate.sh /usr/local/bin/migrate.sh
ADD run.sh /usr/local/bin/run.sh

EXPOSE 80

CMD ["/usr/local/bin/run.sh"]

