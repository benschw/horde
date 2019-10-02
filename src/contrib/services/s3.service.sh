#!/bin/bash


services::s3() {
	local ip=$(net::bridge_ip)
	local name="s3"
	local hostname="s3.horde"

	net::configure_hosts "${hostname}" || return 1

	container::call run \
		-d \
		--name $name \
		--dns $ip \
		--name s3 \
		-p 9000 \
		-e "SERVICE_9000_NAME=${name}" \
		-e "SERVICE_9000_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_9000_TAGS=urlprefix-${hostname}/,service" \
		-e "MINIO_ACCESS_KEY=horde" \
		-e "MINIO_SECRET_KEY=horde_secret" \
		minio/minio server /export
}
