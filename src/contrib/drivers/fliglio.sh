#!/bin/bash

drivers::fliglio() {
	local ip=$(net::bridge_ip)
	local name=$(config::get_name)


	local image=$(config::get_image "benschw/horde-fliglio")
	local hostTags=$(container::build_host_tags "/" $(config::get_hosts))
	local links_arg=$(container::build_links_string $(config::get_services))
	local env_file_arg=$(container::build_env_file_arg $(config::get_env_file))

	local docs=$(pwd)

	container::call run \
		-d \
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
