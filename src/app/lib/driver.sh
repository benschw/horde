#!/bin/bash


driver::run() {
	local driver="$1"
	local name="$2"
	
	if container::is_running "$name"; then
		echo "$name already running"
		return 0
	fi

	driver::_is_valid "$driver" || return 1
	
	container::delete_stopped $name || return 1

	drivers::${driver}::up || return 1
}


#
# Private
#

driver::_is_valid() {
	local driver="$1"
	
	local fcns=( "up" )

	for fcn in "${fcns[@]}" ; do
		if ! util::func_exists "drivers::${driver}::${fcn}" ; then
			util::err "Invalid driver '${driver}'"
			util::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done
}

