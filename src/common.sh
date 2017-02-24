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
	echo $HORDE_IP
}

horde::cfg_hostname() {
	local hostname=$1
	local ip=$(horde::bridge_ip)

	if ! sudo hostess add $hostname $ip ; then
		horde::err "problem configuring hostname '${hostname}'"
		return 1
	fi
}

horde::_hostname() {
	local name=$(horde::config::get_host)
	if [ "${name}" != "null" ] ; then
		echo $name
		return
	fi

	local name=$(horde::config::get_name)

	echo $name.horde
}

horde::configure_hosts() {
	local postfix=$1
	local hostname=$(horde::_hostname)
	local hosts=$(horde::config::get_hosts)
	local hostsCsv=""

	SAVEIFS=$IFS
	IFS=$'\n'
	hosts=($hosts)
	# Restore IFS
	IFS=$SAVEIFS

	hosts+=($hostname)

	for var in "${hosts[@]}"
	do
		if [ ${#hostsCsv} -gt 0 ]; then 
			hostsCsv="$hostsCsv, urlprefix-$var$1"
		else 
			hostsCsv="urlprefix-$var$1"
		fi

		horde::cfg_hostname "${var}" >> /dev/null || return 1
	done

	echo $hostsCsv
}

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

