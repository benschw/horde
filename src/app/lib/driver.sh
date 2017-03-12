#!/bin/bash


driver::run() {
	local driver="$1"
	local name="$2"
	
	if container::is_running "$name"; then
		echo "$name already running"
		return 0
	fi
	
	local app="drivers::${driver}"

	
	if ! util::func_exists "${app}" ; then
		io::err "Driver $driver not found"
		return 1
	fi

	container::delete_stopped $name || return 1
	drivers::${driver} || return 1
}
