#!/bin/bash

horde_help() {
	echo "USAGE:"
	echo "    horde command [name]"
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

horde_up() {
	horde_run
	sleep 3
	horde_provision
}

horde_run() {
	local driver=$(_config_value "driver")
	local name=$(_config_value "name")
	local ip=$(_bridge_ip)
	local hostname=$(_hostname)

	_delete_stopped $name

	_ensure_running registrator
	_ensure_running fabio

	sudo hostess add $hostname $ip

	_${driver}_run
}

horde_provision() {
	local driver=$(_config_value "driver")

	_${driver}_provision
}

horde_logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(_config_value "name")
	fi
	docker logs -f $name
}

horde_stop() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(_config_value "name")
	fi
	docker stop $name
}


command -v hostess >/dev/null 2>&1 || {
	echo >&2 "hostess (https://github.com/cbednarski/hostess) is required to manage names.  Aborting.";
	exit 1;
}
command -v docker >/dev/null 2>&1 || {
	echo >&2 "docker (https://www.docker.com/) is required to manage containers.  Aborting.";
	exit 1;
}


ARGS=( "$@" )
unset ARGS[0]

horde_$1 "${ARGS[@]}"
