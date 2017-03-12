#!/bin/bash


services::chinchilla() {
	local ip=$(net::bridge_ip)
	local name="chinchilla"

	container::delete_stopped chinchilla || return 1

	service::ensure_running rabbitmq || return 1
	service::ensure_running consul || return 1


	container::run \
		-d \
		--name $name \
		--dns $ip \
		--link consul:consul \
		benschw/horde-chinchilla || return 1
}
