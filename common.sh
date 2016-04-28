#!/bin/bash

kdev_del_stopped(){
	local name=$1
	local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm $name
	fi
}
kdev_relies_on(){
	local names=$@

	for name in $names; do
		local state=$(docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$name is not running, starting it for you."
			kdev_$name
		fi
	done
}

kdev_docker_bridge_ip(){
	ifconfig | grep -A 1 docker | tail -n 1 | awk '{print substr($2,6)}'
}
