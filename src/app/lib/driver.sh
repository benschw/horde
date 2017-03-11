#!/bin/bash


horde::driver::run() {
	
	if horde::container::is_running "$name"; then
		echo "$name already running"
		return 0
	fi

	horde::driver::_is_valid "$driver" || return 1
	
	horde::service::delete_stopped $name || return 1

	${driver}::up || return 1
}


#
# Private
#

horde::driver::_is_valid() {
	local driver="$1"
	
	local fcns=( "up" )

	for fcn in "${fcns[@]}" ; do
		if ! horde::func_exists "${driver}::${fcn}" ; then
			horde::err "Invalid driver '${driver}'"
			horde::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done
}

