#!/bin/bash


service::consul() {
	local ip=$(horde::bridge_ip)
	local dns=8.8.8.8
	local hostname="consul.horde"

	if [ ! -z ${HORDE_DNS} ]; then
		dns="$HORDE_DNS"
	fi
	horde::delete_stopped consul || return 1

	horde::cfg_hostname "${hostname}" || return 1

	docker run -d \
		-p 8500:8500 \
		-p "$ip:53:8600/udp" \
		--name=consul \
		-e "SERVICE_8500_CHECK_HTTP=/ui/#/dc1" \
		-e "SERVICE_8500_TAGS=urlprefix-${hostname}/,service" \
		gliderlabs/consul-server:latest -bootstrap -advertise=$ip -recursor=$dns || return 1
	sleep 3
}

service::registrator() {
	local ip=$(horde::bridge_ip)

	horde::delete_stopped registrator || return 1
	
	horde::ensure_running consul || return 1

	docker run -d \
		--name=registrator \
		--net=host \
		--volume=/var/run/docker.sock:/tmp/docker.sock \
		gliderlabs/registrator:latest \
		-ip $ip consul://localhost:8500 || return 1
}

service::fabio() {
	local ip=$(horde::bridge_ip)
	local hostname="fabio.horde"

	horde::delete_stopped fabio || return 1

	horde::cfg_hostname "${hostname}" || return 1

	docker run -d \
		-p 80:80 \
		-p 9998:9998 \
		-e "registry_consul_addr=${ip}:8500" \
		-e "proxy_addr=:80" \
		-e "SERVICE_9998_CHECK_HTTP=/" \
		-e "SERVICE_9998_TAGS=urlprefix-${hostname}/,service" \
		--name=fabio \
		magiconair/fabio || return 1
}

service::mysql() {
	local ip=$(horde::bridge_ip)
	local name="mysql"
	local port_cfg=""

	horde::delete_stopped mysql || return 1
	if [  -z ${HORDE_MYSQL_PUBLISH_PORT+x} ]; then
		port_cfg="3306"
	else
		port_cfg="${HORDE_MYSQL_PUBLISH_PORT}:3306"
	fi

	docker run -d \
		-p $port_cfg \
		-e "SERVICE_3306_NAME=${name}" \
		--name $name \
		--dns $ip \
		benschw/horde-mysql || return 1

	sleep 5
}
service::chinchilla() {
	local ip=$(horde::bridge_ip)
	local name="chinchilla"

	horde::delete_stopped chinchilla || return 1

	horde::ensure_running rabbitmq || return 1
	horde::ensure_running consul || return 1


	docker run -d \
		--name $name \
		--dns $ip \
		--link consul:consul \
		benschw/horde-chinchilla || return 1
}

service::rabbitmq() {
	local ip=$(horde::bridge_ip)
	local name="rabbitmq"
	local hostname="rabbitmq.horde"

	horde::delete_stopped rabbitmq || return 1

	horde::cfg_hostname "${hostname}" || return 1

	docker run -d \
		-p 5672 \
		-p 15672 \
		-e "SERVICE_5672_NAME=${name}" \
		-e "SERVICE_15672_CHECK_HTTP=/" \
		-e "SERVICE_15672_TAGS=urlprefix-${hostname}/,service" \
		--name $name \
		--dns $ip \
		benschw/horde-rabbitmq || return 1
	sleep 3
}

service::splunk() {
	local ip=$(horde::bridge_ip)
	local name="splunk"
	local hostname="splunk.horde"
    local logs=$(pwd)
	local port_cfg="1514:1514"

	horde::delete_stopped splunk || return 1

	horde::cfg_hostname "${hostname}" || return 1

	docker run -d \
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

service::logspout() {
	local ip=$(horde::bridge_ip)
	local name="logspout"

	horde::delete_stopped logspout || return 1

	horde::ensure_running splunk || return 1

	docker run -d \
		--name $name \
		--dns $ip \
		-v /var/run/docker.sock:/var/run/docker.sock \
		gliderlabs/logspout syslog+tcp://$ip:1514 || return 1

	sleep 5
}

