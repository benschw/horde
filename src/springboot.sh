#!/bin/bash

springboot::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local db=$(horde::config::get_db)
	local image=$(horde::config::get_image)

	docker run -d \
		-P\
		-e "SERVICE_8080_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8080_NAME=${name}" \
		-e "SERVICE_8080_TAGS=urlprefix-${hostname}/,springboot" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		${image} \
		|| return 1

}

