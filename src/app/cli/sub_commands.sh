#!/bin/bash
horde::cli::help() {
	horde::cli::_get_usage
}

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

	if [ ! -f ./horde.json ]; then
		echo "./horde.json not found"
		return 1
	fi

	local driver=$(horde::config::get_driver)
	local name=$(horde::config::get_name)

	horde::service::ensure_running $(horde::config::get_services) || return 1
	horde::hosts::configure_hosts $(horde::config::get_hosts) || return 1

	horde::driver::run "$driver" "$name" || return 1
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

horde::cli::register() {
	local name="$1"
	local host="$2"
	local port="$3"
	horde::consul::register "$name" "$host" "$port"
}

horde::cli::deregister() {
	local name="$1"
	horde::consul::deregister "$name"
}
