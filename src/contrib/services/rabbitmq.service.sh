#!/bin/bash



services::rabbitmq() {
	local ip=$(net::bridge_ip)
	local name="rabbitmq"
	local hostname="rabbitmq.horde"

	net::configure_hosts "${hostname}" || return 1

	container::call run \
		-d \
		-p 5672 \
		-p 15672 \
		-e "SERVICE_5672_NAME=${name}" \
		-e "SERVICE_15672_CHECK_HTTP=/" \
		-e "SERVICE_15672_TAGS=urlprefix-${hostname}/,service" \
		--hostname rabbitmq.horde \
		--name $name \
		--dns $ip \
		rabbitmq:3.6-management || return 1
	sleep 3
}

