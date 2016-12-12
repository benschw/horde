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
horde::config::get_env_file() {
	horde::config::_get_value "env_file" || return 1
}
horde::config::get_health() {
	horde::config::_get_value "health" || return 1
}
horde::config::get_db() {
	horde::config::_get_value "db" || return 1
}
horde::config::get_image() {
	horde::config::_get_value "image" || return 1
}
horde::config::get_driver() {
	horde::config::_load_driver || return 1
}
#
# Private
#

horde::config::_get_value() {
	cat ./horde.json | jq -r ".$1"
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
