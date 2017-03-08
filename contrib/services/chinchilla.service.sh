#!/bin/bash


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
