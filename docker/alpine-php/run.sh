#!/bin/sh

function shut_down() {
    pkill -SIGTERM supervisord
	exit
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Configure NGINX
if test "$DOC_ROOT" != ""; then
	sed -i "s+/var/www/httpdocs+$DOC_ROOT+" /etc/nginx/sites-available/default
fi

if test "$FLIGLIO_ENV" != ""; then
	sed -i "s+FLIGLIO_ENV local+FLIGLIO_ENV $FLIGLIO_ENV+" /etc/nginx/sites-available/default
fi

if test "$MYSQL_PORT_3306_TCP_ADDR" != ""; then
	sed -i "s+MYSQL_PORT_3306_TCP_ADDR null+MYSQL_PORT_3306_TCP_ADDR $MYSQL_PORT_3306_TCP_ADDR+" /etc/nginx/sites-available/default
fi
if test "$MYSQL_USER_NAME" != ""; then
	sed -i "s+MYSQL_USER_NAME null+MYSQL_USER_NAME $MYSQL_USER_NAME+" /etc/nginx/sites-available/default
fi
if test "$MYSQL_PASSWORD" != ""; then
	sed -i "s+MYSQL_PASSWORD null+MYSQL_PASSWORD $MYSQL_PASSWORD+" /etc/nginx/sites-available/default
fi
if test "$DATABASE_NAME" != ""; then
	sed -i "s+DATABASE_NAME null+DATABASE_NAME $DATABASE_NAME+" /etc/nginx/sites-available/default
fi


# DB Migrations

if test "${DATABASE_NAME}" != "null" ; then

	DB_USER="$MYSQL_USER_NAME"
	DB_PASS="$MYSQL_PASSWORD"

	MIGRATIONS_PATH_ABS="/var/www/db/migrations"
	if test "$MIGRATIONS_PATH" != ""; then
		MIGRATIONS_PATH_ABS=$MIGRATIONS_PATH
	fi


	mysql -h $MYSQL_PORT_3306_TCP_ADDR -P 3306 -u $DB_USER -p$DB_PASS \
		-e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"


	DB_HOST=$MYSQL_PORT_3306_TCP_ADDR DB_PORT=3306 DB_NAME="$DATABASE_NAME" \
		DB_USER=$DB_USER DB_PASS=$DB_PASS DB_PATH="$MIGRATIONS_PATH_ABS" \
		/usr/bin/php /var/www/vendor/bin/phinx migrate -c /etc/phinx.php -e dev


fi

# chinchilla

if [ -f /var/www/chinchilla.yml ]; then
	if [ -f /var/www/vendor/bin/chinchilla ]; then
		/var/www/vendor/bin/chinchilla
	fi
fi


# Start nginx

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &
wait
