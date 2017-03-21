#!/bin/bash

function shut_down() {
    pkill -SIGTERM supervisord
	exit
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Configure NGINX
if test "$DOC_ROOT" != ""; then
	sed -i "s+/var/www/httpdocs+$DOC_ROOT+" /etc/nginx/sites-available/default
fi

# Start nginx

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &
wait
