#!/bin/bash

fliglio::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local db=$(horde::config::get_db)

	local env_file=$(horde::config::get_env_file)
	local env_file_arg=""
	if [ "${env_file}" != "null" ] ; then
		env_file_arg="--env-file ${env_file}"
	fi
	if [[ "horde::config::get_db" != "null" ]]; then
		horde::ensure_running mysql || return 1
	fi

	docker run -d \
		-P ${env_file_arg} \
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,fliglio" \
		-e "FLIGLIO_ENV=horde" \
		-e "DB_NAME=${db}" \
		-e "MIGRATIONS_PATH=/var/www/migrations" \
		-v "${docs}:/var/www/" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		benschw/horde-fliglio \
		|| return 1

}
