#!/bin/bash

horde::delete_stopped(){
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm $name
	fi
}
horde::ensure_running(){
	local names=$@

	for name in $names; do
		local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$name is not running, starting it for you."
			horde::service::$name
		fi
	done
}

horde::bridge_ip(){
	if [ -z ${HORDE_IP+x} ]; then
		ifconfig | grep -A 1 docker | tail -n 1 | awk '{print substr($2,6)}'
	else 
		echo $HORDE_IP
	fi
}

horde::config_value() {
	cat ./horde.json | jq -r ".$1"
}

horde::load_driver() {
	local driver=$(horde::config_value "driver")
	
	local fcns=( "run" "provision" )

	for fcn in "${fcns[@]}" ; do
		if ! horde::fcn_exists "${driver}::${fcn}" ; then
			horde::err "Invalid driver '${driver}'"
			horde::err "${driver}::${fcn} not implemented"
			return 1
		fi
	done

	echo $driver
	return 0
}

horde::fcn_exists() {
	local fcn=$1
	
	if [ -n "$(type -t $fcn)" ] && [ "$(type -t $fcn)" = "function" ] ; then
		return 0
	else
		return 1
	fi
}

horde::hostname() {
	local name=$(horde::config_value "name")

	echo $name.horde
}

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

