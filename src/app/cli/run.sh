#!/bin/bash

horde::cli::up() {
	local svc_names=("$@")
	horde::cli::run "${svc_names[@]}"
}

horde::cli::run() {
	local svc_names=("$@")
	
	if [ "${#svc_names[@]}" -ne 0 ]; then
		horde::service::ensure_running "${svc_names[@]}" || return 1
		return 0
	fi

	horde::driver::run || return 1
}

horde::cli::restart() {
	horde::cli::stop "$@"
	horde::cli::run "$@"
}

horde::cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config::get_name)
	fi
	docker logs -f $name
}

horde::cli::kill() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(horde::config::get_name) )
	fi
	docker kill "${names[@]}"
}

horde::cli::stop() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(horde::config::get_name) )
	fi
	docker stop "${names[@]}"
}
