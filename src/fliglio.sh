#!/bin/bash




fliglio::run() {
	local ip=$(horde::bridge_ip)
	local hostname=$(horde::hostname)
	local name=$(horde::config::get_name)
	local health=$(horde::config::get_health)
	local docs=$(pwd)

	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_HTTP=${health}" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,fliglio" \
		-e "FLIGLIO_ENV=horde" \
		-v "${docs}:/var/www/" \
		--name $name \
		--dns $ip \
		fliglio/local-dev
}

fliglio::provision() {

	local name=$(horde::config::get_name)
	local docs=$(pwd)
	local db=$(horde::config::get_db)


	if [[ "$db" != "null" ]]; then
		docker run \
			-v $docs:/var/www/ \
			-e "DB_NAME=$db" \
			-e "MIGRATIONS_PATH=/var/www/migrations" \
			--link ${name}:localdev \
			fliglio/local-dev \
			/usr/local/bin/migrate.sh
	fi
}
