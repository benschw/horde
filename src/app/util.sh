#!/bin/bash

horde::cmd_exists() {
	local cli="$1"
	local error_msg="$2"

	command -v "$cli" >/dev/null 2>&1 || {
		horde::msg "$error_msg"
		return 1
	}
}

horde::func_exists() {
	local f=$1
	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

horde::err() {
	echo "ERROR: $@" >&2
}

horde::msg() {
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

