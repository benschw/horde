#!/bin/bash

main() {
	util::cmd_exists "hostess" "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting." \
		|| return 1
	util::cmd_exists "docker" "docker (https://www.docker.com/) is required to manage containers. Aborting." \
		|| return 1
	util::cmd_exists "jq" "jq (https://stedolan.github.io/jq/) is required for parsing json. Aborting." \
		|| return 1

	plugin_mgr::load "$HOME/.horde/plugins"

	if net::ensure_osx_vboxnet ; then
		net::osx_vboxnet_setup || return 1
	fi
	
	local args=( "$@" )
	unset args[0]

	local sub_cmd="cli::${1}"

	if [ -n "$(type -t $sub_cmd)" ] && [ "$(type -t $sub_cmd)" = function ]; then
		if ! cli::$1 "${args[@]}" ; then
			util::err "Fatal Error. Exiting"
			return 1
		fi
	else
		util::msg "Unknown subcommand '${1}'"
	fi
}

main "$@" || exit 1

