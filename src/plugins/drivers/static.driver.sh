#!/bin/bash

static_web::up() {
	local ip=$(horde::net::bridge_ip)
	local name=$(horde::config::get_name)


	local image=$(horde::config::get_image "benschw/horde-fliglio")
	local hostTags=$(horde::container::build_host_tags "/" $(horde::config::get_hosts))
	local links_arg=$(horde::container::build_links_string $(horde::config::get_services))
	local env_file_arg=$(horde::container::build_env_file_arg $(horde::config::get_env_file))

	local docs=$(pwd)

	docker run -d \
		--name "${name}" \
		--dns "${ip}" \
		-P $env_file_arg $links_arg \
		-v "${docs}:/var/www" \
		-e "SERVICE_80_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},static-web" \
		"${image}" \
		|| return 1
}
