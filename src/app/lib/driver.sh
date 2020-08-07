#!/bin/bash

driver::assert_installed() {
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		if ! util::func_exists "drivers::${name}"; then
			io::err "Driver '${name}' not installed"
			plugin_mgr::find "$name"
			return 1
		fi
	done
}

driver::run() {
	local driver="$1"
	local name="$2"
	
	if container::is_running "$name"; then
		echo "$name already running"
		return 0
	fi
	
	local app="drivers::${driver}"

	driver::assert_installed "$driver" || return 1

	container::delete_stopped $name || return 1
	drivers::${driver} || return 1
}
