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

horde::hostname() {
	local name=$(horde::config_value "name")

	echo $name.horde
}

horde::err() {
	echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@" >&2
}

