#!/bin/bash

horde::func_exists() {
	local f=$1
	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

horde::valid_driver() {
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

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

horde::debug() {
	echo $@ >&2
}

horde::trace() {
	echo $@ >&2
	local i=0
	local stack=(${FUNCNAME[@]})
	unset stack[0]
	for fcn in "${stack[@]}" ; do
		echo $i: $fcn >&2
		i=$((i+1))
	done
}

