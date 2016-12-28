#!/bin/bash

horde::delete_stopped(){
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm $name
	fi
}
horde::ensure_running(){
	local name=$1

	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
		echo "$name is not running, starting"
		horde::service::$name || return 1
	fi
}

horde::bridge_ip(){
	if [ -z ${HORDE_IP+x} ]; then
		ifconfig | grep -A 1 docker | tail -n 1 | awk '{print $2}'
	else
	    # Check if bridge is up
	    is_bridge_ip_available=$(ifconfig | grep -A 1 docker | grep -w ''"${HORDE_IP}"'' | awk '{print $2}')
	    if [ -z ${is_bridge_ip_available} ]; then
	        is_bridge_ip_available=$(ifconfig | grep -A 2 vboxnet | grep -w ''"${HORDE_IP}"'' | awk '{print $2}')
	    fi

	    # Trying to bring bridge up using VBoxManage
	    vboxmanage=$(command -v VBoxManage 2>/dev/null )
	    if [[ -z ${is_bridge_ip_available} && vboxmanage ]]; then
            available_vbox=$(ifconfig | grep vboxnet | grep -v UP | grep -m 1 vboxnet | awk '{print $1}' | sed 's/://g')

            if [ -z ${available_vbox} ]; then
                available_vbox=$(VBoxManage hostonlyif create)
            fi

            VBoxManage hostonlyif ipconfig $available_vbox -ip $HORDE_IP
	    fi

		echo $HORDE_IP
	fi
}

horde::cfg_hostname() {
	local hostname=$1
	local ip=$(horde::bridge_ip)

	if ! sudo hostess add $hostname $ip ; then
		horde::err "problem configuring hostname '${hostname}'"
		return 1
	fi
}

horde::hostname() {
	local name=$(horde::config::get_host)
	if [ "${name}" != "null" ] ; then
		echo $name
		return
	fi

	local name=$(horde::config::get_name)

	echo $name.horde
}

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

