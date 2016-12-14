#!/bin/bash


horde::service::consul() {
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

horde::service::registrator() {
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

horde::service::fabio() {
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

horde::service::mysql() {
	local ip=$(horde::bridge_ip)
	local name="mysql"

	horde::delete_stopped mysql || return 1

	docker run -d \
		-p 3306 \
		-e "SERVICE_3306_NAME=${name}" \
		--name $name \
		--dns $ip \
		benschw/horde-mysql || return 1

	sleep 5
}
horde::service::chinchilla() {
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

horde::service::rabbitmq() {
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


