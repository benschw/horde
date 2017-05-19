#!/bin/bash

services::vault() {
	local ip=$(net::bridge_ip)
	container::delete_stopped vault || return 1
	local name="vault"
    local logs=$(pwd)

	container::call run \
		-d \
		-p 8200:8200 \
		--name vault \
		--cap-add=IPC_LOCK \
		-e VAULT_DEV_ROOT_TOKEN_ID=horde \
		--dns ${ip} \
		vault:0.6.5 || return 1
	sleep 3

}
services::vault::horde_user() {
	services::vault::cli vault auth-enable userpass
	services::vault::cli vault write auth/userpass/users/horde \
		password=horde \
		policies=admins
	services::vault::cli 'echo "{\"path\":{\"*\":{\"policy\":\"sudo\"}}}" | vault policy-write admins -'
}
services::vault::cli() {
	local args=("$@")
	local cmd='export VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200; '"${args[@]}"
	container::call run \
		-it \
		--rm \
		--link vault:vault \
		-e VAULT_TOKEN=horde \
		vault:0.6.5  \
		/bin/sh -c "$cmd" \
		|| return 1
}
