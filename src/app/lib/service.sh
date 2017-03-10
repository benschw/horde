#!/bin/bash


horde::service::delete_stopped(){
	local name=$1

	if horde::container::exists "$name"; then
		if ! horde::container::is_running "$name"; then
			docker rm $name
		fi
	fi
}

horde::service::ensure_running(){
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		if ! horde::container::is_running "$name"; then

			local svc="service::${name}"

			if ! horde::func_exists "${svc}"; then
				horde::err "Service '${name}' not found"
				return 1
			fi
			echo "Starting $name"
			$svc || return 1
		fi
	done
}
