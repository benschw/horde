#!/bin/bash

horde::start_services() {
	local services=$(horde::config::get_services)
	SAVEIFS=$IFS
	IFS=$'\n'
	services=($services)
	# Restore IFS
	IFS=$SAVEIFS

	services=("consul" "${services[@]}")
	services=("registrator" "${services[@]}")
	services=("fabio" "${services[@]}")


	local links_args=""
	for svc in "${services[@]}"; do
		horde::service::ensure_running "${svc}" || return 1
	done
}
horde::get_service_links() {
	local services=$(horde::config::get_services)
	SAVEIFS=$IFS
	IFS=$'\n'
	services=($services)
	# Restore IFS
	IFS=$SAVEIFS

	services=("consul" "${services[@]}")

	local links_args=""
	for svc in "${services[@]}"; do
		links_args="${links_args} --link ${svc}:${svc}"
	done
	echo $links_args
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
