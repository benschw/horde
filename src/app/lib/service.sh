#!/bin/bash

service::assert_installed() {
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		if ! util::func_exists "services::${name}"; then
			io::err "Service '${name}' not installed"
			plugin_mgr::find "$name"
			return 1
		fi
	done
}

service::ensure_running() {
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

	service::assert_installed "$name" || return 1

	echo "Starting $name"
	container::delete_stopped "$name" || return 1
	$svc || return 1
}
