#!/bin/bash


services::consul() {
	local ip=$(net::bridge_ip)
	local dns=$(net::default_dns)
	local hostname="consul.horde"

	net::configure_hosts "${hostname}" || return 1

	container::call run \
		-d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		-e "SERVICE_8500_CHECK_HTTP=/ui/#/dc1" \
		-e "SERVICE_8500_TAGS=urlprefix-${hostname}/,service" \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=$dns || return 1
	sleep 3
}

