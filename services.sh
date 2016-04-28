#!/bin/bash

# edit `/etc/systemd/system/multi-user.target.wants/docker.service` to contain:
# `ExecStart=/usr/bin/docker daemon --dns 172.17.0.1 -H fd://¬`
# and run `sudo systemctl daemon-reload` and `sudo service docker restart`

kdev_consul() {
	ip=$(kdev_docker_bridge_ip)

	kdev_del_stopped consul

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=8.8.8.8
}

kdev_registrator() {
	ip=$(kdev_docker_bridge_ip)

	kdev_del_stopped registrator
	
	kdev_relies_on consul

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest -ip $ip consul://localhost:8500
}

kdev_fabio() {
	ip=$(kdev_docker_bridge_ip)

	kdev_del_stopped fabio

	docker run -d \
		-p 80:9999 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "SERVICE_IGNORE=true" \
		--name=fabio \
		magiconair/fabio
}
