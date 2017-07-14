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

	container::call run \
		-d \
		-p $port_cfg \
		-e "SERVICE_3306_NAME=${name}" \
		--name $name \
		--dns $ip \
		benschw/horde-mysql || return 1

	sleep 5
}

services::mysql::create_database() {
	db_name="${1//-/_}"

	container::call run -it --rm \
		--link mysql:mysql \
		benschw/horde-mysql \
		sh -c 'exec mysql -h$MYSQL_PORT_3306_TCP_ADDR -u admin -pchangeme -e "CREATE DATABASE IF NOT EXISTS '$db_name'"'

}
