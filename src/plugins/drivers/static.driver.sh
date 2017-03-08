#!/bin/bash

static_web::up() {
	local ip=$(horde::bridge_ip)
	local hostTags=$(horde::configure_hosts "/")
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},static-web" \
		-v "${docs}:/var/www/" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		benschw/horde-fliglio \
		|| return 1
}
