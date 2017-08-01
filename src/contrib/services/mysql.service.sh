#!/bin/bash

services::mysql() {
	local ip=$(net::bridge_ip)
	local name="mysql"
	local port_cfg=""

	if [  -z ${HORDE_MYSQL_PUBLISH_PORT+x} ]; then
		port_cfg="3306"
	else
		port_cfg="${HORDE_MYSQL_PUBLISH_PORT}:3306"
	fi

	container::call run -d \
		-p $port_cfg $mysql_volume_arg \
		-e "SERVICE_3306_NAME=${name}" \
		-e "MYSQL_ALLOW_EMPTY_PASSWORD=yes" \
		--name $name \
		--dns $ip \
		mysql:5.7 || return 1

	echo "Waiting for MySQL to start up"
	ctr=$((25))
	secs=$ctr
	while [ $secs -gt 0 ]; do

		left=$secs
		while [ $left -gt 0 ]; do
			echo -n "."
			: $((left--))
		done
		left=$secs
		while [ $left -lt $ctr ]; do
			echo -n ' '
			: $((left++))
		done
		echo -ne "\r"
		sleep 1
		: $((secs--))
	done
	
	container::call run -it --rm --link mysql:mysql mysql:5.7 \
		sh -c 'exec mysql -h$MYSQL_PORT_3306_TCP_ADDR -u root -e "GRANT ALL ON *.* TO admin@'\''%'\'' IDENTIFIED BY '\''changeme'\'' WITH GRANT OPTION; FLUSH PRIVILEGES"'
}


services::mysql::create_database() {
	db_name="${1//-/_}"

	container::call run -it --rm \
		--link mysql:mysql \
		mysql:5.7 \
		sh -c 'exec mysql -h$MYSQL_PORT_3306_TCP_ADDR -u admin -pchangeme -e "CREATE DATABASE IF NOT EXISTS '$db_name'"'

}
