#!/bin/bash


service::delete_stopped(){
	local name=$1

	if container::exists "$name"; then
		if ! container::is_running "$name"; then
			docker rm $name
		fi
	fi
}

service::ensure_running(){
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		if ! container::is_running "$name"; then

			local svc="services::${name}"

			if ! util::func_exists "${svc}"; then
				util::err "Service '${name}' not found"
				return 1
			fi
			echo "Starting $name"
			$svc || return 1
		fi
	done
}
