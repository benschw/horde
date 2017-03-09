#!/bin/bash
#
# Manage reading from config
#

horde::config::get_name() {
	horde::config::_get_value "name" || return 1
}
horde::config::get_host() {
	horde::config::_get_value "host" || return 1
}
horde::config::get_env_file_arg() {
	local env_file=$(horde::config::get_env_file)

	if [ "${env_file}" != "null" ] ; then
		echo "--env-file ${env_file}"
	fi
}
horde::config::get_env_file() {
	horde::config::_get_value "env_file" || return 1
}
horde::config::get_health() {
	horde::config::_get_value "health" || return 1
}
horde::config::get_image() {
	local default="$1"
	local val=$(horde::config::_get_value "image")
	if [ "$val" == "null" ]; then
		echo $default
	else
		echo $val
	fi
}
horde::config::get_driver() {
	horde::config::_load_driver || return 1
}
horde::config::get_hosts() {
	horde::config::_get_array "hosts" || return 1
}
horde::config::get_services() {
	horde::config::_get_array "services" || return 1
	local svc=""
	echo $HORDE_SERVICES | sed -n 1'p' | tr ',' '\n' | while read svc; do
    	echo $svc
	done

}
#
# Private
#

horde::config::_get_value() {
	jq -r ".$1" ./horde.json
}

horde::config::_get_array() {
	if jq -e 'has("'"$1"'")' ./horde.json > /dev/null; then
		jq -r ".$1"' | join("\n")' ./horde.json
	fi
}

horde::config::_load_driver() {
	local driver=$(horde::config::_get_value "driver")
	
	local fcns=( "up" )

	for fcn in "${fcns[@]}" ; do
		if ! horde::config::_fcn_exists "${driver}::${fcn}" ; then
			horde::err "Invalid driver '${driver}'"
			horde::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done

	echo $driver
	return 0
}

horde::config::_fcn_exists() {
	local fcn=$1
	
	if [ -n "$(type -t $fcn)" ] && [ "$(type -t $fcn)" = "function" ] ; then
		return 0
	else
		return 1
	fi
}
