#!/bin/bash

horde::func_exists() {
	local f=$1
	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
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

