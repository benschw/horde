#!/bin/bash


fliglio::up() {
	local ip=$(horde::bridge_ip)
	local hostTags=$(horde::configure_hosts "/")
	local name=$(horde::config::get_name)

	local env_file=$(horde::config::get_env_file)
	local env_file_arg=""

	if [ "${env_file}" != "null" ] ; then
		env_file_arg="--env-file ${env_file}"
	fi
	

	local vol_arg=""
	local image=$(horde::config::get_image)
	if [ "${image}" == "null" ] ; then
		image="benschw/horde-fliglio"

		local docs=$(pwd)
		vol_arg="-v ${docs}:/var/www/" 
	fi

	horde::ensure_running logspout || return 1

	docker run -d \
		-P ${env_file_arg} ${vol_arg} \
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},fliglio" \
		-e "FLIGLIO_ENV=horde" \
		-e "MIGRATIONS_PATH=/var/www/migrations" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1

}

fliglio_gw::up() {
	local ip=$(horde::bridge_ip)
	local hostTags=$(horde::configure_hosts "/api/")
	local name=$(horde::config::get_name)

	local env_file=$(horde::config::get_env_file)
	local env_file_arg=""

	if [ "${env_file}" != "null" ] ; then
		env_file_arg="--env-file ${env_file}"
	fi

	local vol_arg=""
	local image=$(horde::config::get_image)
	if [ "${image}" == "null" ] ; then
		image="benschw/horde-fliglio"

		local docs=$(pwd)
		vol_arg="-v ${docs}:/var/www/" 
	fi

	horde::ensure_running chinchilla || return 1

	horde::ensure_running logspout || return 1

	if [[ "horde::config::get_db" != "null" ]]; then
		horde::ensure_running mysql || return 1
	fi

	docker run -d \
		-P ${env_file_arg} ${vol_arg} \
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=${hostTags},fliglio_gw" \
		-e "FLIGLIO_ENV=horde" \
		-e "MIGRATIONS_PATH=/var/www/migrations" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1
}

