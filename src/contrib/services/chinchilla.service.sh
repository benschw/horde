#!/bin/bash


services::chinchilla() {
	local ip=$(net::bridge_ip)
	local name="chinchilla"

	service::ensure_running rabbitmq || return 1
	service::ensure_running consul || return 1
	service::ensure_running vaultui || return 1

	local secret_path=./.chinchilla_secrets.yml
	echo "- key: rabbitmq_password" >> $secret_path
	echo "  plaintext: True" >> $secret_path
	echo "  value: guest" >> $secret_path

	services::springboard::setup "${name}"
	services::springboard::write_vault_secrets "${name}" "${secret_path}"
	local secret=$(services::springboard::new_secret "${name}")
	
	rm "${secret_path}"

	container::call run \
		-d \
		--name $name \
		-e "CONSUL_HTTP_ADDR=http://${ip}:8500" \
		-e "VAULT_APPROLE_PATH=s3://horde/${name}-role-id" \
		-e "VAULT_APPROLE_SECRET_ID=${secret}" \
		-e "AWS_ACCESS_KEY_ID=horde" \
		-e "AWS_SECRET_ACCESS_KEY=horde_secret" \
		-e "AWS_DEFAULT_REGION=us-east-1" \
		-e RABBITMQ_USER=guest \
		-e RABBITMQ_PASSWORD=guest \
		-e RABBITMQ_SERVICENAME=rabbitmq \
		-e RABBITMQ_VHOST= \
		--dns $ip \
		--link consul:consul \
		benschw/horde-chinchilla || return 1
}
