#!/bin/bash -x

sb::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local image=$(horde::config::get_image)

	local env_file=$(horde::config::get_env_file)
	local env_file_arg=""
	if [ "${env_file}" != "null" ] ; then
		env_file_arg="--env-file ${env_file}"
	fi

    local java_opts_arg=""
    local remote_debug_port_arg=""
    local remote_debug_port=$(horde::config::get_remote_debug_port)
	if [ "${remote_debug_port}" != "null" ] ; then
		java_opts_arg="-e \"JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,address=${remote_debug_port},server=y,suspend=n\""
		remote_debug_port_arg="-p ${remote_debug_port}:${remote_debug_port}"
	fi

	horde::ensure_running mysql || return 1

	horde::ensure_running logspout || return 1

	docker run -d \
		-P ${env_file_arg} \
        ${java_opts_arg} \
        ${remote_debug_port_arg} \
		-e "SERVICE_8080_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8080_NAME=${name}" \
		-e "SERVICE_8080_TAGS=urlprefix-${hostname}/,springboot" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1
	

}

sb_gw::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local docs=$(pwd)

	local image=$(horde::config::get_image)

	local env_file=$(horde::config::get_env_file)
	if [ "${env_file}" != "null" ] ; then
		env_file="--env-file ${env_file}"
	fi

	docker run -d \
		-P\
		-e "SERVICE_8080_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8080_NAME=${name}" \
		-e "SERVICE_8080_TAGS=urlprefix-${hostname}/api/,springboot" \
		${env_file} \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		"${image}" \
		|| return 1

}


sb_gw_web::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local docs=$(pwd)


	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,angular-web" \
		-e "FLIGLIO_ENV=horde" \
		-v "${docs}/dist:/var/www/httpdocs/" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		benschw/horde-fliglio \
		|| return 1

}
