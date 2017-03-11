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

horde::net::ensure_osx_vboxnet() {
	if [ ${HORDE_ENSURE_VBOXNET+x} ]; then
		return 0
	else
		return 1
	fi
}

horde::net::osx_vboxnet_setup() {
	local ip=$(horde::net::bridge_ip)
	command -v VBoxManage >/dev/null 2>&1 || {
		horde::err "VirtualBox (https://www.virtualbox.org/) is required to create consul bridge. Aborting."
		return 1
	}

	# Check if vboxnet0 exist, if not we create it and assing bridge IP to it
	is_bridge_ip_available=$(ifconfig | grep vboxnet0 | awk '{print $1}')
	if [ -z ${is_bridge_ip_available} ]; then
		VBoxManage hostonlyif create
		VBoxManage hostonlyif ipconfig vboxnet0 -ip $ip
	fi
}

