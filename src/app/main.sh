#!/bin/bash



main() {

	command -v hostess >/dev/null 2>&1 || {
		horde::debug  "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting."
		return 1
	}

	command -v docker >/dev/null 2>&1 || {
		horde::debug "docker (https://www.docker.com/) is required to manage containers. Aborting."
		return 1
	}

	command -v jq >/dev/null 2>&1 || {
		horde::debug "jq (https://stedolan.github.io/jq/) is required for parsing json. Aborting."
		return 1
	}

	horde::net::ensure_osx_vboxnet && horde::net::osx_vboxnet_setup
	
	local args=( "$@" )
	unset args[0]

	local sub_cmd="horde::cli::${1}"


	if [ -n "$(type -t $sub_cmd)" ] && [ "$(type -t $sub_cmd)" = function ]; then
		if ! horde::cli::$1 "${args[@]}" ; then
			horde::err "Fatal Error. Exiting"
			return 1
		fi
	else
		horde::err "Invalid subcommand '${1}'"
	fi

}


