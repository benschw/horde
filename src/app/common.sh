#!/bin/bash

horde::start_services() {
	local services=("$@")

	local links_args=""
	for svc in "${services[@]}"; do
		horde::service::ensure_running "${svc}" || return 1
	done
}
horde::configure_hosts() {
	local hosts=("$@")

	for var in "${hosts[@]}"; do
		horde::cfg_hostname "${var}" >> /dev/null || return 1
	done
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

