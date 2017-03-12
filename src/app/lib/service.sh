#!/bin/bash


service::ensure_running(){
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		service::_load "$name" || return 1
	done
}

service::_load() {
	local name="$1"

	if container::is_running "$name"; then
		return 0
	fi

	local svc="services::${name}"

	if ! util::func_exists "${svc}"; then
		util::err "Service '${name}' not found"
		return 1
	fi

	echo "Starting $name"
	$svc || return 1
}
