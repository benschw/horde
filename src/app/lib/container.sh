#!/bin/bash

horde::container::get_service_links() {
	horde::container::_build_links_string $(horde::config::get_services)
}
horde::container::_build_links_string() {
	local services=("$@")

	local links_args=""
	local mode=""
	for svc in "${services[@]}"; do
		#can't link to registrator because it uses --net=host
		mode=$(horde::container::get_network_mode "$svc")
		if [[ "$mode" != "host" ]]; then
			links_args="${links_args} --link ${svc}:${svc}"
		fi
	done
	echo $links_args
}


horde::container::get_env_file_arg() {
	local env_file=$(horde::config::get_env_file)

	if [ "${env_file}" != "null" ] ; then
		echo "--env-file ${env_file}"
	fi
}

horde::container::get_host_tags() {
	local postfix=$1
	local hosts=$(horde::config::get_hosts)
	local hostsCsv=""

	SAVEIFS=$IFS
	IFS=$'\n'
	hosts=($hosts)
	# Restore IFS
	IFS=$SAVEIFS

	for var in "${hosts[@]}"; do
		if [ ${#hostsCsv} -gt 0 ]; then 
			hostsCsv="${hostsCsv}, urlprefix-${var}${postfix}"
		else 
			hostsCsv="urlprefix-${var}${postfix}"
		fi

	done

	echo $hostsCsv
}
horde::container::get_network_mode() {
	local svc=$1
	docker inspect --format "{{.HostConfig.NetworkMode}}" $svc 2>/dev/null
}
horde::container::is_running() {
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
		return 1
	fi
	return 0
}


