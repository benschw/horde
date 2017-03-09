#!/bin/bash

horde::cli::run() {
	local svc_names=( "$@" )
	horde::cli::up "${svc_names[@]}"
}

horde::cli::up() {
	local svc_names=( "$@" )
	
	if [ "${#svc_names[@]}" -ne 0 ]; then
		horde::ensure_running "${svc_names[@]}" || return 1
		return 0
	fi

	if [ ! -f ./horde.json ]; then
		echo "./horde.json not found"
		return 1
	fi

	local driver=$(horde::config::get_driver)
	local name=$(horde::config::get_name)
	local ip=$(horde::bridge_ip)

	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)
	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then

		horde::service::delete_stopped $name || return 1

		horde::start_services || return 1

		${driver}::up || return 1
		return 0
	fi
	echo "${name} already running"

}
