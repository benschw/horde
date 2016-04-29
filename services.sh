#!/bin/bash


kdev_consul() {
	ip=$(_bridge_ip)

	_delete_stopped consul

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=8.8.8.8
}

kdev_registrator() {
	ip=$(_bridge_ip)

	_delete_stopped registrator
	
	_ensure_running consul

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest -ip $ip consul://localhost:8500
}

kdev_fabio() {
	ip=$(_bridge_ip)

	_delete_stopped fabio

	docker run -d \
		-p 80:9999 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "SERVICE_IGNORE=true" \
		--name=fabio \
		magiconair/fabio
}
