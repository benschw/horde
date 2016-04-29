#!/bin/bash

kdev_help() {
	echo "USAGE:"
	echo "    kdev command [name]"
	echo
	echo "COMMANDS:"
	echo "    up        short hand for \`run\` and \`provision\`"
	echo "    logs      follow the logs for a container"
	echo "    stop      stop a fliglio app"
	echo "    run       run a fliglio app"
	echo "    provision run database migrations on a running fliglio app"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"driver\": \"fliglio\","
	echo "        \"name\": \"container-name\","
	echo "        \"health\": \"/path/to/health-check\","
	echo "        \"db\": \"db_name\""
	echo "    }"
}

kdev_up() {
	kdev_run
	sleep 3
	kdev_provision
}

kdev_run() {
	local driver=$(_config_value "driver")
	local name=$(_config_value "name")
	local ip=$(_bridge_ip)
	local hostname=$(_hostname)

	_delete_stopped $name

	_ensure_running registrator
	_ensure_running fabio

	sudo hostess add $hostname 127.0.0.1

	_${driver}_run
}

kdev_provision() {
	local driver=$(_config_value "driver")

	_${driver}_provision
}

kdev_logs() {
	name=$1
	if [ -z ${1+x} ]; then
		name=$(_config_value "name")
	fi
	docker logs -f $name
}

kdev_stop() {
	name=$1
	if [ -z ${1+x} ]; then
		name=$(_config_value "name")
	fi
	docker stop $name
}


ARGS=( "$@" )
unset ARGS[0]

kdev_$1 "${ARGS[@]}"
