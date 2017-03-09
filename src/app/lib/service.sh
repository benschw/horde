#!/bin/bash


horde::service::delete_stopped(){
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm $name
	fi
}
horde::service::ensure_running(){
	local names=( "$@" )
	local name=""

	for name in "${names[@]}"; do

		local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

		local svc="service::${name}"

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			if ! horde::func_exists "${svc}"; then
				horde::err "Service '${name}' not found"
				return 1
			fi
			echo "Starting $name"
			$svc || return 1
		fi
	done
}
