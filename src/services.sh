#!/bin/bash


horde::service::consul() {
	local ip=$(horde::bridge_ip)
	local dns=8.8.8.8

	if [ ! -z ${HORDE_DNS} ]; then
		dns="$HORDE_DNS"
	fi

	horde::delete_stopped consul

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=$dns
}

horde::service::registrator() {
	local ip=$(horde::bridge_ip)

	horde::delete_stopped registrator
	
	horde::ensure_running consul

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest -ip $ip consul://localhost:8500
}

horde::service::fabio() {
	local ip=$(horde::bridge_ip)

	horde::delete_stopped fabio

	docker run -d \
		-p 80:80 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "proxy_addr=:80" \
		-e "SERVICE_IGNORE=true" \
		--name=fabio \
		magiconair/fabio
}
