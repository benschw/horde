#!/bin/bash
#
# horde::cli subcommand definitions


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
	horde::cli::run || return 1
	sleep 3
	horde::cli::provision || return 1
}

horde::cli::run() {
	local driver=$(horde::config::get_driver)
	local name=$(horde::config::get_name)
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)

	horde::delete_stopped $name || return 1

	horde::ensure_running registrator || return 1
	horde::ensure_running fabio || return 1

	if ! sudo hostess add $hostname $ip ; then
		horde::err "problem configuring hostname '${hostname}'"
		return 1
	fi

	${driver}::run || return 1
}

horde::cli::provision() {
	local driver=$(horde::config::get_driver)
	${driver}::provision || return 1
}

horde::cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config::get_name)
	fi
	docker logs -f $name
}

horde::cli::stop() {
	local names="$@"
	if [ -z ${1+x} ]; then
		names=( $(horde::config::get_name) )
	fi
	docker stop ${names[@]}
}
