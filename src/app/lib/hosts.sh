#!/bin/bash

horde::hosts::configure_hosts() {
	local hosts=("$@")
	local ip=$(horde::bridge_ip)

	for host in "${hosts[@]}"; do
		horde::hosts::_configure_host "$ip" "$host" || return 1
	done
}

horde::hosts::_configure_host() {
	local ip=$1
	local hostname=$2

	if ! sudo hostess add $hostname $ip > /dev/null ; then
		horde::err "problem configuring hostname '${hostname}'"
		return 1
	fi
}

