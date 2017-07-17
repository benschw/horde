#!/bin/bash

services::fabio() {
	local ip=$(net::bridge_ip)
	local hostname="fabio.horde"

	net::configure_hosts "${hostname}" || return 1

	container::call run \
		-d \
		-p 80:80 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "proxy_addr=:80" \
		-e "SERVICE_9998_CHECK_HTTP=/" \
		-e "SERVICE_9998_TAGS=urlprefix-${hostname}/,service" \
		--name=fabio \
		magiconair/fabio || return 1
}

