#!/bin/bash

hosts::configure() {
	local hosts=("$@")
	local ip=$(net::bridge_ip)

	for host in "${hosts[@]}"; do
		hosts::_configure "$ip" "$host" || return 1
	done
}

hosts::_configure() {
	local ip=$1
	local hostname=$2

	if ! sudo hostess add $hostname $ip > /dev/null ; then
		util::err "problem configuring hostname '${hostname}'"
		return 1
	fi
}

