#!/bin/bash


horde::driver::run() {
	if [ ! -f ./horde.json ]; then
		echo "./horde.json not found"
		return 1
	fi

	local driver=$(horde::config::get_driver)
	local name=$(horde::config::get_name)
	
	if horde::container::is_running "$name"; then
		echo "$name already running"
		return 0
	fi

	horde::driver::_is_valid "$driver" || return 1
	
	horde::service::delete_stopped $name || return 1

	horde::service::ensure_running $(horde::driver::_get_services) || return 1
	horde::hosts::configure_hosts $(horde::driver::_get_hosts) || return 1

	${driver}::up || return 1
}

horde::driver::get_service_links() {
	horde::container::build_links_string $(horde::driver::_get_services)
}

horde::driver::get_env_file_arg() {
	horde::container::build_env_file_arg $(horde::config::get_env_file)
}

horde::driver::get_host_tags() {
	local postfix=$1
	local hosts=$(horde::driver::_get_hosts)

	horde::container::build_host_tags "$postfix" "$hosts" || return 1
}

#
# Private
#

horde::driver::_get_hosts() {
	local name=$(horde::config::get_name)
	if [ "${name}" != "null" ] ; then
		horde::config::get_host "${name}.horde"
	fi

	horde::config::get_hosts
}

horde::driver::_get_services() {
	echo consul
	echo registrator
	echo fabio

	horde::config::get_services || return 1
	
	local svc=""
	echo $HORDE_SERVICES | sed -n 1'p' | tr ',' '\n' | while read svc; do
    	echo $svc
	done
}

horde::driver::_is_valid() {
	local driver="$1"
	
	local fcns=( "up" )

	for fcn in "${fcns[@]}" ; do
		if ! horde::func_exists "${driver}::${fcn}" ; then
			horde::err "Invalid driver '${driver}'"
			horde::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done
}

