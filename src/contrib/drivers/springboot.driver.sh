#!/bin/bash

sb::up() {
	local ip=$(horde::net::bridge_ip)
	local hostTags=$(horde::configure_hosts "/")
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local image=$(horde::config::get_image)

	local env_file=$(horde::config::get_env_file)
	local env_file_arg=""
	if [ "${env_file}" != "null" ] ; then
		env_file_arg="--env-file ${env_file}"
	fi


	docker run -d \
		-P ${env_file_arg} \
		--expose 5005 \
		-e "SERVICE_8080_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8080_NAME=${name}" \
		-e "SERVICE_8080_TAGS=${hostTags},springboot" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1
	

}

sb_gw::up() {
	local ip=$(horde::net::bridge_ip)
	local hostTags=$(horde::configure_hosts "/api/")
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local image=$(horde::config::get_image)

	local env_file=$(horde::config::get_env_file)
	if [ "${env_file}" != "null" ] ; then
		env_file="--env-file ${env_file}"
	fi

	docker run -d \
		-P\
		--expose 5005 \
		-e "SERVICE_8080_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8080_NAME=${name}" \
		-e "SERVICE_8080_TAGS=${hostTags},springboot" \
		${env_file} \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1

}


sb_gw_web::up() {
	local ip=$(horde::net::bridge_ip)
	local hostTags=$(horde::configure_hosts "/")
	local name=$(horde::config::get_name)
	local docs=$(pwd)


	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},angular-web" \
		-e "FLIGLIO_ENV=horde" \
		-v "${docs}/dist:/var/www/httpdocs/" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		benschw/horde-fliglio \
		|| return 1

}
