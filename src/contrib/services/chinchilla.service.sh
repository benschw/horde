#!/bin/bash


service::chinchilla() {
	local ip=$(horde::net::bridge_ip)
	local name="chinchilla"

	horde::service::delete_stopped chinchilla || return 1

	horde::service::ensure_running rabbitmq || return 1
	horde::service::ensure_running consul || return 1


	docker run -d \
		--name $name \
		--dns $ip \
		--link consul:consul \
		benschw/horde-chinchilla || return 1
}
