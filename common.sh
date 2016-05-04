#!/bin/bash

_delete_stopped(){
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm $name
	fi
}
_ensure_running(){
	local names=$@

	for name in $names; do
		local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$name is not running, starting it for you."
			_service_$name
		fi
	done
}

_bridge_ip(){
	if [ -z ${HORDE_IP+x} ]; then
		ifconfig | grep -A 1 docker | tail -n 1 | awk '{print substr($2,6)}'
	else 
		echo $HORDE_IP
	fi
}

_config_value() {
	cat ./horde.json | jq -r ".$1"
}

_hostname() {
	local name=$(_config_value "name")

	echo $name.horde
}

