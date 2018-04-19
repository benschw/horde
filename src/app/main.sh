#!/bin/bash
_ensure_osx_vboxnet() {
	[ ${HORDE_ENSURE_VBOXNET+x} ] || return 1
}

_osx_vboxnet_setup() {
	local ip=$(net::bridge_ip)

	if ! util::cmd_exists "VBoxManage" ; then
		io::err "VirtualBox (https://www.virtualbox.org/) is required to create consul bridge. Aborting."
		return 1
	fi

	# Check if vboxnet0 exist, if not we create it and assing bridge IP to it
	is_bridge_ip_available=$(ifconfig | grep vboxnet0 | awk '{print $1}')
	if [ -z ${is_bridge_ip_available} ]; then
		VBoxManage hostonlyif create
		VBoxManage hostonlyif ipconfig vboxnet0 -ip $ip
	fi
}

main() {
	if ! util::cmd_exists "hostess" ; then
		io::err "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting."
		return 1
	fi
	if ! util::cmd_exists "docker" ; then
		io::err "docker (https://www.docker.com/) is required to manage containers. Aborting."
		return 1
	fi
	if ! util::cmd_exists "jq" ; then
		io::err "jq (https://stedolan.github.io/jq/) is required for parsing json. Aborting."
		return 1
	fi

	plugin_mgr::load "$HOME/.horde/plugins"

	if _ensure_osx_vboxnet ; then
		_osx_vboxnet_setup || return 1
	fi
	
	local args=("$@")
	unset args[0]

	local sub_cmd="cli::${1}"

	if ! util::func_exists "$sub_cmd" ; then
		if ! cli::custom "${1}" "${args[@]}" ; then
			return 1
		fi
		return 0
	fi

	if ! cli::$1 "${args[@]}" ; then
		return 1
	fi
}

main "$@" || exit 1

