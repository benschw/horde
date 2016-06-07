#!/bin/bash



main() {


	command -v hostess >/dev/null 2>&1 || {
		horde::err  "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting."
		exit 1
	}

	command -v docker >/dev/null 2>&1 || {
		horde::err "docker (https://www.docker.com/) is required to manage containers. Aborting."
		exit 1
}

	local args=( "$@" )
	unset args[0]

	local sub_cmd="horde::cli::${1}"

	if [ -n "$(type -t $sub_cmd)" ] && [ "$(type -t $sub_cmd)" = function ]; then
		if ! horde::cli::$1 "${args[@]}" ; then
			horde::err "Fatal Error. Exiting"
			exit 1
		fi

	else
		horde::err "Invalid subcommand '${1}'"
	fi

}

main "$@"
