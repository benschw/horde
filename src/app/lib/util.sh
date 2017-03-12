#!/bin/bash

util::cmd_exists() {
	local cli="$1"
	local error_msg="$2"

	command -v "$cli" >/dev/null 2>&1 || {
		util::msg "$error_msg"
		return 1
	}
}

util::func_exists() {
	local f=$1
	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

util::msg() {
	echo $@ >&2
}

util::err() {
	echo "ERROR: $@" >&2
}

util::trace() {
	echo $@ >&2
	local i=0
	local stack=(${FUNCNAME[@]})
	unset stack[0]
	for fcn in "${stack[@]}" ; do
		echo $i: $fcn >&2
		i=$((i+1))
	done
}

