#!/bin/bash

container::call() {
	local args=("$@")

	if [ ! -z "$HORDE_DEBUG" ]; then
		io::err "docker ${args[@]}"
	fi
	
	docker "${args[@]}" || return 1
}

container::is_running() {
	local name=$1
	local state=$(container::call inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]] || [[ "$state" == "" ]] || [[ "$state" == "exited" ]]; then
		return 1
	fi
	return 0
}

container::delete_stopped(){
	local name=$1

	if container::_exists "$name"; then
		if ! container::is_running "$name"; then
			container::call rm $name
		fi
	fi
}

container::build_links_string() {
	local services=("$@")

	local links_args=""
	local mode=""
	for svc in "${services[@]}"; do
		#can't link to registrator because it uses --net=host
		mode=$(container::_get_network_mode "$svc")
		if [[ "$mode" != "host" ]]; then
			links_args="${links_args} --link ${svc}:${svc}"
		fi
	done
	echo $links_args
}

container::build_env_file_arg() {
	local env_file=$1

	if [ "${env_file}" != "null" ] ; then
		echo "--env-file ${env_file}"
	fi
}

container::build_host_tags() {
	local postfix=$1
	local hosts=($@)
	unset hosts[0]

	local hostsCsv=""

	for var in "${hosts[@]}"; do
		if [ ${#hostsCsv} -gt 0 ]; then 
			hostsCsv="${hostsCsv},urlprefix-${var}${postfix}"
		else 
			hostsCsv="urlprefix-${var}${postfix}"
		fi

	done
	echo $hostsCsv
}

#
# Private
#

container::_get_network_mode() {
	local svc=$1
	container::call inspect --format "{{.HostConfig.NetworkMode}}" $svc 2>/dev/null
}

container::_exists() {
	local name=$1
	local state=$(container::call inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "" ]]; then
		return 1
	fi
}

