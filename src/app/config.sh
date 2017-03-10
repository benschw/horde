#!/bin/bash
#
# Manage reading from config
#

horde::config::get_name() {
	horde::json::value "name" || return 1
}
horde::config::get_host() {
	horde::json::value "host" || return 1
}
horde::config::get_env_file() {
	horde::json::value "env_file" || return 1
}
horde::config::get_driver() {
	horde::config::_load_driver || return 1
}
horde::config::get_health() {
	horde::json::value "health" || return 1
}

horde::config::get_image() {
	local default="$1"
	local val=$(horde::json::value "image")
	if [ "$val" == "null" ]; then
		echo $default
	else
		echo $val
	fi
}

horde::config::get_hosts() {
	local name=$(horde::config::get_host)
	if [ "${name}" != "null" ] ; then
		echo $name
		return
	fi

	local name=$(horde::config::get_name)

	echo $name.horde
	horde::json::array "hosts" || return 1
}

horde::config::get_services() {
	echo consul
	echo registrator
	echo fabio

	horde::json::array "services" || return 1
	
	local svc=""
	echo $HORDE_SERVICES | sed -n 1'p' | tr ',' '\n' | while read svc; do
    	echo $svc
	done

}
#
# Private
#


horde::config::_load_driver() {
	local driver=$(horde::json::value "driver")
	
	local fcns=( "up" )

	for fcn in "${fcns[@]}" ; do
		if ! horde::func_exists "${driver}::${fcn}" ; then
			horde::err "Invalid driver '${driver}'"
			horde::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done

	echo $driver
	return 0
}

