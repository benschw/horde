#!/bin/bash

horde::cli::help() {
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

horde::cli::up() {
	horde::cli::run
	sleep 3
	horde::cli::provision
}

horde::cli::run() {
	local driver=$(horde::config_value "driver")
	local name=$(horde::config_value "name")
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)

	horde::delete_stopped $name

	horde::ensure_running registrator
	horde::ensure_running fabio

	sudo hostess add $hostname $ip

	${driver}::run
}

horde::cli::provision() {
	local driver=$(horde::config_value "driver")

	${driver}::provision
}

horde::cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config_value "name")
	fi
	docker logs -f $name
}

horde::cli::stop() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config_value "name")
	fi
	docker stop $name
}
