#!/bin/bash

cli::init() {
	local name=$1
	initializer::init ${name} || return 1
}

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

	if ! config::is_valid ; then
		io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
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
		if ! config::is_valid ; then
			io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
			return 1
		fi
		name=$(config::get_name)
	fi
	container::call logs -f $name
}

cli::kill() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		if ! config::is_valid ; then
			io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
			return 1
		fi
		names=( $(config::get_name) )
	fi
	container::call kill "${names[@]}"
}

cli::stop() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		if ! config::is_valid ; then
			io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
			return 1
		fi
		names=( $(config::get_name) )
	fi
	container::call stop "${names[@]}"
}

cli::sh() {
	local name=$1
	if [ -z ${1+x} ]; then
		if ! config::is_valid ; then
			io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
			return 1
		fi
		name=$(config::get_name)
	fi
	container::call exec -it "$name" /bin/sh || return 1
}

cli::bash() {
	local name=$1
	if [ -z ${1+x} ]; then
		if ! config::is_valid ; then
			io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
			return 1
		fi
		name=$(config::get_name)
	fi
	container::call exec -it "$name" /bin/bash || return 1
}

cli::custom() {
	local sub_cmd="$1"
	if ! config::is_valid ; then
		io::err "${FUNCNAME[0]} ./horde.json has bad format or not found"
		return 1
	fi
	driver=$(config::get_driver)

	if ! util::func_exists "drivers::$driver::$sub_cmd" ; then
		io::err "Unknown subcommand: '${1}'"
		echo
		cli::help
		return 1
	fi

	drivers::$driver::$sub_cmd || return 1
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
	echo "    horde command [options]"
	echo
	echo "COMMANDS:"
	echo "    init [driver_name]             use driver_name.initializer.sh to initialize this directory"
	echo "    run [name]                   start up an app or service"
	echo "    stop [name]                  stop an app or service"
	echo "    restart [name]               alias for stop and up"
	echo "    kill [name]                  kill a fliglio app"
	echo "    logs [name]                  follow the logs for a container"
	echo "    bash [name]                  exec a bash shell in a running app or container"
	echo "    sh [name]                    exec as sh shell in a running app or container"
	echo "    register name domain port    register an external service with consul"
	echo "    deregister name              deregister an external service"
	echo "    help                         display this help text and exit"
	echo
	echo "    (name can refer to a service or an app. if omitted, the value in"
	echo "    ./horde.json is used)"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"driver\": \"static\","
	echo "        \"name\": \"container-name\""
	echo "    }"
	echo
	echo "    (to use an alternate horde definition, use HORDE_CONFIG=/path/to/alt.json"
	echo "    e.g. HORDE_CONFIG=./other-horde.json horde run )"
	echo
	echo "See https://github.com/benschw/horde/ for more details"
}
