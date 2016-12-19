#!/bin/bash
horde::util::is_fcn() {
	local fcn="$1"
	if [ -n "$(type -t $fcn)" ] && [ "$(type -t $fcn)" = function ]; then
		return 0
	fi
	return 1
}
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

horde::identify_driver() {
	local name="$1"
	local tagLine=$(horde::consul::get_tags "$name")

	IFS=' ' read -ra tags <<< "$tagLine"

	for tag in "${tags[@]}"; do

		local test_tag=$(echo $tag | cut -c 1-6)

		if [ "$test_tag" == "horde-" ]; then
			echo "$tag" | cut -c 7-
			return 0
		fi

	done

	horde::err "could not identify driver for service '$name'"
	return 1
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

