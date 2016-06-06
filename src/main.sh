#!/bin/bash


command -v hostess >/dev/null 2>&1 || {
	horde::err  "hostess (https://github.com/cbednarski/hostess) is required to manage names.  Aborting."
	exit 1
}
command -v docker >/dev/null 2>&1 || {
	horde::err "docker (https://www.docker.com/) is required to manage containers.  Aborting."
	exit 1
}


ARGS=( "$@" )
unset ARGS[0]

horde::cli::$1 "${ARGS[@]}"

