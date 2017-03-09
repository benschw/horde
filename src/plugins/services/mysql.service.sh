#!/bin/bash



service::mysql() {
	local ip=$(horde::bridge_ip)
	local name="mysql"
	local port_cfg=""

	horde::service::delete_stopped mysql || return 1
	if [  -z ${HORDE_MYSQL_PUBLISH_PORT+x} ]; then
		port_cfg="3306"
	else
		port_cfg="${HORDE_MYSQL_PUBLISH_PORT}:3306"
	fi

	docker run -d \
		-p $port_cfg \
		-e "SERVICE_3306_NAME=${name}" \
		--name $name \
		--dns $ip \
		benschw/horde-mysql || return 1

	sleep 5
}
