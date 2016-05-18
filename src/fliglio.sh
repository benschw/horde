#!/bin/bash




_fliglio_run() {
	local ip=$(_bridge_ip)
	local hostname=$(_hostname)
	local name=$(_config_value "name")
	local health=$(_config_value "health")
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

_fliglio_provision() {

	local name=$(_config_value "name")
	local docs=$(pwd)
	local db=$(_config_value "db")

	if [ ! -z "$db"} ]; then
		docker run \
			-v $docs:/var/www/ \
			-e "DB_NAME=$db" \
			-e "MIGRATIONS_PATH=/var/www/migrations" \
			--link ${name}:localdev \
			fliglio/local-dev \
			/usr/local/bin/migrate.sh
	fi
}
