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

	svc="service::${name}"
	
	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
		if ! horde::func_exists "${svc}"; then
			horde::err "Service '${name}' not found"
			return 1
		fi
		echo "Starting $name"
		$svc || return 1
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

horde::load_services() {
	local services=$(horde::config::get_services)
	SAVEIFS=$IFS
	IFS=$'\n'
	services=($services)
	# Restore IFS
	IFS=$SAVEIFS

	horde::ensure_running consul || return 1
	horde::ensure_running registrator || return 1
	horde::ensure_running fabio || return 1

	for svc in "${services[@]}"; do
		horde::ensure_running "${svc}"
	done
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

horde::func_exists() {
	local f=$1
	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

