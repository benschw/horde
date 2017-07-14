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

services::registrator() {
	local ip=$(net::bridge_ip)

	service::ensure_running consul || return 1

	container::call run \
		-d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest \
		-ip $ip -cleanup consul://localhost:8500 || return 1
}

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
