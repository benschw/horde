#!/bin/bash

util::cmd_exists() {
	local cli="$1"

	command -v "$cli" >/dev/null 2>&1 || return 1
}

util::func_exists() {
	local f=$1

	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

