#!/bin/bash

horde::bridge_ip(){
	horde::trace "horde::bridge_ip is deprecated, use horde::net::bridge_ip"
	horde::net::bridge_ip
}

horde::net::bridge_ip(){
	echo $HORDE_IP
}

horde::net::default_dns() {
	local dns=8.8.8.8

	if [ ! -z "$HORDE_DNS" ]; then
		dns="$HORDE_DNS"
	fi

	echo $dns
}
