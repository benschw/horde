#!/bin/bash

fliglio::up() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local health=$(horde::config::get_health)
	local docs=$(pwd)

	local db=$(horde::config::get_db)

	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_HTTP=${health}" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,fliglio" \
		-e "FLIGLIO_ENV=horde" \
		-e "DB_NAME=${db}" \
		-e "MIGRATIONS_PATH=/var/www/migrations" \
		-v "${docs}:/var/www/" \
		--name "${name}" \
		--dns "${ip}" \
		--link consul:consul \
		--link mysql:mysql \
		benschw/horde-fliglio \
		|| return 1

}
