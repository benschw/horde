#!/bin/bash

services::splunk() {
	local ip=$(net::bridge_ip)
	local name="splunk"
	local hostname="splunk.horde"
    local logs=$(pwd)
	local port_cfg="1514:1514"

	service::delete_stopped splunk || return 1

	service::ensure_running logspout || return 1

	hosts::configure "${hostname}" || return 1

	container::run \
		-d \
		-p $port_cfg \
		-p "8000" \
        -e "SERVICE_1514_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8000_NAME=${name}" \
        -e "SERVICE_8000_CHECK_SCRIPT=echo ok" \
		-e "SERVICE_8000_TAGS=urlprefix-${hostname}/,service" \
		-e "SPLUNK_START_ARGS=--accept-license" \
		-e "SPLUNK_USER=root" \
		-e "SPLUNK_ADD=tcp 1514 -sourcetype log4j" \
        -v "${logs}/splunk-logs" \
		--name $name \
		--dns $ip \
		splunk/splunk || return 1

    mkdir -p ./system/local
    echo $'[jsvcs_host]\nDEST_KEY = MetaData:Host\nREGEX = <\d+>\d{1}\s{1}\S+\s{1}\S+\s{1}(\S+)\nFORMAT = host::$1' >./system/local/transforms.conf
    echo $'[source::tcp:1514]\nTRANSFORMS-service=jsvcs_host\nSHOULD_LINEMERGE = false' >./system/local/props.conf

	sleep 5

	docker cp ./system splunk:opt/splunk/etc
	rm -rf ./system

	sleep 5
}

services::logspout() {
	local ip=$(net::bridge_ip)
	local name="logspout"

	service::delete_stopped logspout || return 1


	container::run \
		-d \
		--name $name \
		--dns $ip \
		-v /var/run/docker.sock:/var/run/docker.sock \
		gliderlabs/logspout syslog+tcp://$ip:1514 || return 1

	sleep 5
}

