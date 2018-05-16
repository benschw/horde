#!/bin/bash



services::memcached() {
	local ip=$(net::bridge_ip)
	local name="memcached"
	local hostname="memcached.horde"

	net::configure_hosts "${hostname}" || return 1

	container::call run \
		-d \
		-p 11211 \
		-e "SERVICE_11211_NAME=${name}" \
		-e "SERVICE_15672_CHECK_SCRIPT=true" \
		-e "SERVICE_15672_TAGS=urlprefix-${hostname}/,service" \
		--hostname "${hostname}" \
		--name $name \
		--dns $ip \
		memcached:1.5.7 || return 1
	sleep 3
}


