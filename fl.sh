#!/bin/bash

kdev_help() {
	echo "USAGE:"
	echo "    kdev command"
	echo
	echo "COMMANDS:"
	echo "    up       short hand for \`run\` and \`migrate\`"
	echo "    logs     follow the logs for a container"
	echo "    destroy  stop a fliglio app"
	echo "    run      run a fliglio app"
	echo "    migrate  run database migrations on a running fliglio app"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"name\": \"container-name\","
	echo "        \"health\": \"/path/to/health-check\","
	echo "        \"db\": \"db_name\""
	echo "    }"
}




kdev_up() {
	kdev_run
	sleep 3
	kdev_migrate
}

kdev_run() {
	local ip=$(kdev_docker_bridge_ip)
	local name=$(kdev_config_value "name")
	local health=$(kdev_config_value "health")
	local docs=$(pwd)

	kdev_del_stopped $name

	kdev_relies_on registrator
	kdev_relies_on fabio

	sudo hostess add $name.fl 127.0.0.1

	docker run -d \
		-P\
		-e "SERVICE_80_CHECK_HTTP=${health}" \
		-e "SERVICE_80_NAME=${name}" \
		-e "SERVICE_80_TAGS=urlprefix-${name}.fl/,fl-app" \
		-v "${docs}:/var/www/" \
		--name $name \
		--dns $ip \
		fliglio/local-dev
}

kdev_migrate() {
	local name=$(kdev_config_value "name")
	local docs=$(pwd)
	local db=$(kdev_config_value "db")

	docker run \
		-v $docs:/var/www/ \
		-e "DB_NAME=$db" \
		--link ${name}:localdev \
		fliglio/local-dev \
		/usr/local/bin/migrate.sh
}

kdev_logs() {
	docker logs -f $(kdev_config_value "name")
}
kdev_stop() {
	docker stop $(kdev_config_value "name")
}
kdev_destroy() {
	kdev_stop
	kdev_del_stopped $(kdev_config_value "name")
}

kdev_config_value() {
	cat ./fl.json | jq -r ".$1"
}


ARGS=( "$@" )
unset ARGS[0]

kdev_$1 "${ARGS[@]}"
