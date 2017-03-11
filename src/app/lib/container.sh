#!/bin/bash

horde::container::is_running() {
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
		return 1
	fi
	return 0
}

horde::container::exists() {
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "" ]]; then
		return 1
	fi
}

horde::container::build_links_string() {
	local services=("$@")

	local links_args=""
	local mode=""
	for svc in "${services[@]}"; do
		#can't link to registrator because it uses --net=host
		mode=$(horde::container::_get_network_mode "$svc")
		if [[ "$mode" != "host" ]]; then
			links_args="${links_args} --link ${svc}:${svc}"
		fi
	done
	echo $links_args
}

horde::container::build_env_file_arg() {
	local env_file=$1

	if [ "${env_file}" != "null" ] ; then
		echo "--env-file ${env_file}"
	fi
}

horde::container::build_host_tags() {
	local postfix=$1
	local hosts=($@)
	unset hosts[0]

	local hostsCsv=""

	for var in "${hosts[@]}"; do
		if [ ${#hostsCsv} -gt 0 ]; then 
			hostsCsv="${hostsCsv}, urlprefix-${var}${postfix}"
		else 
			hostsCsv="urlprefix-${var}${postfix}"
		fi

	done
	echo $hostsCsv
}

#
# Private
#

horde::container::_get_network_mode() {
	local svc=$1
	docker inspect --format "{{.HostConfig.NetworkMode}}" $svc 2>/dev/null
}
