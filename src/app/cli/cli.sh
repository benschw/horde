#!/bin/bash
#
# horde::cli subcommand definitions



horde::cli::restart() {
	horde::cli::stop "$@"
	horde::cli::up "$@"
}

horde::cli::logs() {
	local name=$1
	if [ -z ${1+x} ]; then
		name=$(horde::config::get_name)
	fi
	docker logs -f $name
}

horde::cli::kill() {
	local names=( "$@" )
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(horde::config::get_name) )
	fi
	docker kill "${names[@]}"
}
horde::cli::stop() {
	local names=( "$@" )
	if [ "${#names[@]}" -eq 0 ]; then
		names=( $(horde::config::get_name) )
	fi
	docker stop "${names[@]}"
}
