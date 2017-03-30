#!/bin/bash

services::vaultui() {
    local ip=$(horde::bridge_ip)
	local hostname="vault-ui.horde"

    service::ensure_running consul || return 1
    service::ensure_running vault || return 1
	container::delete_stopped vaultui || return 1
	net::configure_hosts "${hostname}" || return 1

	docker run -d \
		-p 80 \
		--name=vaultui \
		-e VAULT_SKIP_VERIFY=True \
		-e VAULT_ADDR=http://$ip:8200 \
		-e "SERVICE_80_CHECK_HTTP=/login" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,service" \
		--dns ${ip}
		nyxcharon/vault-ui:latest || return 1

}