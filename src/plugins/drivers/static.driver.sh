#!/bin/bash

static_web::up() {
	local ip=$(horde::bridge_ip)
	local name=$(horde::config::get_name)

	local image=$(horde::config::get_image "benschw/horde-fliglio")
	local hostTags=$(horde::container::get_host_tags "/")
	local links_arg=$(horde::container::get_service_links)
	local env_file_arg=$(horde::container::get_env_file_arg)

	local docs=$(pwd)

	docker run -d \
		--name "${name}" \
		--dns "${ip}" \
		-P $env_file_arg $links_arg \
		-v "${docs}:/var/www" \
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},static-web" \
		"${image}" \
		|| return 1
}
