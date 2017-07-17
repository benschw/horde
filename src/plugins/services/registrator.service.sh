#!/bin/bash

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


