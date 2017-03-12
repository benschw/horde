#!/bin/bash
_ensure_osx_vboxnet() {
	[ ${HORDE_ENSURE_VBOXNET+x} ] || return 1
}

_osx_vboxnet_setup() {
	local ip=$(net::bridge_ip)

	util::cmd_exists "VBoxManage" "VirtualBox (https://www.virtualbox.org/) is required to create consul bridge. Aborting." \
		|| return 1

	# Check if vboxnet0 exist, if not we create it and assing bridge IP to it
	is_bridge_ip_available=$(ifconfig | grep vboxnet0 | awk '{print $1}')
	if [ -z ${is_bridge_ip_available} ]; then
		VBoxManage hostonlyif create
		VBoxManage hostonlyif ipconfig vboxnet0 -ip $ip
	fi
}


main() {
	util::cmd_exists "hostess" "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting." \
		|| return 1
	util::cmd_exists "docker" "docker (https://www.docker.com/) is required to manage containers. Aborting." \
		|| return 1
	util::cmd_exists "jq" "jq (https://stedolan.github.io/jq/) is required for parsing json. Aborting." \
		|| return 1

	plugin_mgr::load "$HOME/.horde/plugins"

	if _ensure_osx_vboxnet ; then
		_osx_vboxnet_setup || return 1
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

