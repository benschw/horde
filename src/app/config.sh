#!/bin/bash

config::is_valid() {
	[ -f ./horde.json ] || return 1
	jq . ./horde.json 2>&1 > /dev/null || return 1
}

config::get_driver() {
	config::_get_value "driver" "$1"
}
config::get_name() {
	config::_get_value "name" "$1"
}
config::get_python_entry() {
	config::_get_value "python_entry" "$1"
}
config::get_host() {
	config::_get_value "host" "$1"
}
config::get_health() {
	config::_get_value "health" "$1"
}
config::get_env_file() {
	config::_get_value "env_file" "$1"
}
config::get_secrets_file() {
	config::_get_value "secrets_file" "$1"
}
config::get_image() {
	config::_get_value "image" "$1"
}
config::get_hosts() {
	local name=$(config::get_name)
	if [ "${name}" != "null" ] ; then
		config::get_host "${name}.horde"
	fi

	config::_get_array "hosts"
}
config::get_services() {
	echo consul
	echo registrator
	echo fabio

	config::_get_array "services"
	
	local svc=""
	echo $HORDE_SERVICES | sed -n 1'p' | tr ',' '\n' | while read svc; do
    	echo $svc
	done
}

#_
# Private
#

config::_get_value() {
	local key=$1
	local default=$2
	local val=$(config::_json_value ./horde.json "$key")

	if [ "$val" == "null" ]; then
		if [ -z "$default" ]; then
			echo "null"
		else
			echo $default
		fi
	else
		echo $val
	fi
}

config::_get_array() {
	config::_json_array ./horde.json "$1"
}

config::_json_value() {
	local file="$1"
	local key="$2"

	jq -r ".$key" "$file"
}

config::_json_array() {
	local file="$1"
	local key="$2"

	if jq -e 'has("'"$key"'")' $file > /dev/null; then
		jq -r ".$key"' | join("\n")' "$file"
	fi
}

