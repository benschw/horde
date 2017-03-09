#!/bin/bash


app() {

	command -v hostess >/dev/null 2>&1 || {
		horde::err  "hostess (https://github.com/cbednarski/hostess) is required to manage names. Aborting."
		return 1
	}

	command -v docker >/dev/null 2>&1 || {
		horde::err "docker (https://www.docker.com/) is required to manage containers. Aborting."
		return 1
	}

	command -v jq >/dev/null 2>&1 || {
		horde::err "jq (https://stedolan.github.io/jq/) is required for parsing json. Aborting."
		return 1
	}

	if [ ${HORDE_ENSURE_VBOXNET+x} ]; then
    	command -v VBoxManage >/dev/null 2>&1 || {
		    horde::err "VirtualBox (https://www.virtualbox.org/) is required to create consul bridge. Aborting."
    		return 1
	    }

	    # Check if vboxnet0 exist, if not we create it and assing bridge IP to it
	    is_bridge_ip_available=$(ifconfig | grep vboxnet0 |  awk '{print $1}')
	    if [ -z ${is_bridge_ip_available} ]; then
	        VBoxManage hostonlyif create
	        VBoxManage hostonlyif ipconfig vboxnet0 -ip $HORDE_IP
	    fi
	fi
	
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


