#!/bin/bash
#
# horde::cli subcommand definitions


horde::cli::help() {
	echo "USAGE:"
	echo "    horde command [name]"
	echo
	echo "COMMANDS:"
	echo "    up           start up an app (requires horde.json)"
	echo "    logs [name]  follow the logs for a container (uses horde.json"
	echo "                 if a name isn't supplied)"
	echo "    stop [name]  stop a fliglio app (uses horde.json if a name"
	echo "                 isn't supplied)"
	echo "    restart      alias for stop and up (requires horde.json)"
	echo
	echo "    register name domain port    register an external service with consul"
	echo "    deregister name              deregister an external service"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"driver\": \"fliglio\","
	echo "        \"name\": \"container-name\","
	echo "        \"db\": \"db_name\"",
	echo "        \"image\": \"docker/image_tag\"",
	echo "        \"host\": \"hostname_override\"",
	echo "        \"env_file\": \"env_file/to/inject\""
	echo "    }"
}

horde::cli::up() {
	local driver=$(horde::config::get_driver)
	local name=$(horde::config::get_name)
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)

	horde::delete_stopped $name || return 1

	horde::ensure_running registrator || return 1
	horde::ensure_running fabio || return 1


	horde::cfg_hostname "${hostname}" || return 1

	${driver}::up || return 1
}

horde::cli::restart() {
	horde::cli::stop
	horde::cli::up
}

horde::cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config::get_name)
	fi
	docker logs -f $name
}

horde::cli::stop() {
	local name="$1"
	local driver=""

	if [ -z ${1+x} ]; then
		name=( $(horde::config::get_name) )
		driver=( $(horde::config::get_driver) )
	else
		driver=$(horde::identify_driver "$name")
		echo "Driver identified as $driver"
	fi
	
	
	if horde::util::is_fcn "${driver}::stop"; then
		$driver::stop "$name"
	else
		docker stop $name
	fi
}
horde::cli::register() {
	local name="$1"
	local host="$2"
	local port="$3"
	local ip=$(dig +short "${host}")
	local hostname="${name}.horde"

	echo "setting $name"

	horde::cfg_hostname "${hostname}" || return 1
	
	return horde::consul::register $name $ip $port $hostname
}
horde::cli::deregister() {
	local name="$1"

	return horde::consul::deregister "$name"
}
