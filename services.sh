#!/bin/bash


_service_consul() {
	hostname="consul.horde"
	ip=$(_bridge_ip)

	_delete_stopped consul

	sudo hostess add $hostname 127.0.0.1

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		-e "SERVICE_8500_TAGS=urlprefix-$hostname/" \
		--name=consul \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=8.8.8.8
}

_service_registrator() {
	ip=$(_bridge_ip)

	_delete_stopped registrator
	
	_ensure_running consul

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest -ip $ip consul://localhost:8500
}

_service_fabio() {
	ip=$(_bridge_ip)

	_delete_stopped fabio

	docker run -d \
		-p 80:80 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "proxy_addr=:80" \
		-e "SERVICE_IGNORE=true" \
		--name=fabio \
		magiconair/fabio
}
