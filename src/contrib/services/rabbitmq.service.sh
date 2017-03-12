#!/bin/bash



services::rabbitmq() {
	local ip=$(net::bridge_ip)
	local name="rabbitmq"
	local hostname="rabbitmq.horde"

	service::delete_stopped rabbitmq || return 1

	hosts::configure "${hostname}" || return 1

	container::run \
		-d \
		-p 5672 \
		-p 15672 \
		-e "SERVICE_5672_NAME=${name}" \
		-e "SERVICE_15672_CHECK_HTTP=/" \
		-e "SERVICE_15672_TAGS=urlprefix-${hostname}/,service" \
		--name $name \
		--dns $ip \
		benschw/horde-rabbitmq || return 1
	sleep 3
}

