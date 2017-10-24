#!/bin/bash

services::dnsmasq() {
	local ip=$(net::bridge_ip)
	local dns=$(net::default_dns)

	container::call run \
		-d \
		-p 53:53/tcp -p 53:53/udp \
		--dns=$dns \
		--cap-add=NET_ADMIN \
		--name=dnsmasq \
		andyshinn/dnsmasq:2.75 \
			--log-facility=- -q -R \
			--dns-loop-detect \
			--address=/horde/$ip \
			--server="/consul/$ip#8600" \
			--server="$dns" 

}


