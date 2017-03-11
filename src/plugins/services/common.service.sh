#!/bin/bash


service::consul() {
	local ip=$(horde::net::bridge_ip)
	local dns=$(horde::net::default_dns)
	local hostname="consul.horde"

	horde::service::delete_stopped consul || return 1

	horde::hosts::configure_hosts "${hostname}" || return 1

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		-e "SERVICE_8500_CHECK_HTTP=/ui/#/dc1" \
		-e "SERVICE_8500_TAGS=urlprefix-${hostname}/,service" \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=$dns || return 1
	sleep 3
}

service::registrator() {
	local ip=$(horde::net::bridge_ip)

	horde::service::delete_stopped registrator || return 1
	
	horde::service::ensure_running consul || return 1

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest \
		-ip $ip consul://localhost:8500 || return 1
}

service::fabio() {
	local ip=$(horde::net::bridge_ip)
	local hostname="fabio.horde"

	horde::service::delete_stopped fabio || return 1

	horde::hosts::configure_hosts "${hostname}" || return 1

	docker run -d \
		-p 80:80 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "proxy_addr=:80" \
		-e "SERVICE_9998_CHECK_HTTP=/" \
		-e "SERVICE_9998_TAGS=urlprefix-${hostname}/,service" \
		--name=fabio \
		magiconair/fabio || return 1
}
