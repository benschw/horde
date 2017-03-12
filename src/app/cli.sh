#!/bin/bash

cli::up() {
	local svc_names=("$@")
	cli::run "${svc_names[@]}"
}

cli::run() {
	local svc_names=("$@")
	
	if [ "${#svc_names[@]}" -ne 0 ]; then
		service::ensure_running "${svc_names[@]}" || return 1
		return 0
	fi

	if ! config::is_present ; then
		util::msg "./horde.json not found"
		return 1
	fi

	service::ensure_running $(config::get_services) || return 1
	net::configure_hosts $(config::get_hosts) || return 1

	driver::run $(config::get_driver) $(config::get_name) || return 1
}

cli::restart() {
	cli::stop "$@"
	cli::run "$@"
}

cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(config::get_name)
	fi
	docker logs -f $name
}

cli::kill() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(config::get_name) )
	fi
	docker kill "${names[@]}"
}

cli::stop() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(config::get_name) )
	fi
	docker stop "${names[@]}"
}

cli::register() {
	local name="$1"
	local host="$2"
	local port="$3"
	consul::register "$name" "$host" "$port"
}

cli::deregister() {
	local name="$1"
	consul::deregister "$name"
}

cli::help() {
	echo "USAGE:"
	echo "    horde command [name]"
	echo
	echo "COMMANDS:"
	echo "    run [name]      start up an app or service (uses horde.json if a name"
	echo "                    isn't supplied)"
	echo "    stop [name]     stop an app or service (uses horde.json if a name"
	echo "                    isn't supplied)"
	echo "    restart [name]  alias for stop and up (requires horde.json)"
	echo "    kill [name]     kill a fliglio app (uses horde.json if a name"
	echo "                    isn't supplied)"
	echo "    logs [name]     follow the logs for a container (uses horde.json"
	echo "                    if a name isn't supplied)"
	echo
	echo "    register name domain port    register an external service with consul"
	echo "    deregister name              deregister an external service"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"driver\": \"static\","
	echo "        \"name\": \"container-name\""
	echo "    }"
	echo
	echo "See https://github.com/benschw/horde/ for more details"
}

