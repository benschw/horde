#!/bin/bash

horde::config::get_name() {
	horde::config::_get_value "name" "$1" || return 1
}
horde::config::get_host() {
	horde::config::_get_value "host" "$1" || return 1
}
horde::config::get_health() {
	horde::config::_get_value "health" "$1" || return 1
}
horde::config::get_env_file() {
	horde::config::_get_value "env_file" "$1" || return 1
}
horde::config::get_image() {
	horde::config::_get_value "image" "$1" || return 1
}
horde::config::get_driver() {
	horde::config::_get_value "driver" "$1" || return 1
}
horde::config::get_hosts() {
	horde::config::_get_array "hosts"
}
horde::config::get_services() {
	horde::config::_get_array "services"
}

#_
# Private
#

horde::config::_get_value() {
	local key=$1
	local default=$2
	local val=$(horde::config::_json_value ./horde.json "$key")

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

horde::config::_get_array() {
	horde::config::_json_array ./horde.json "$1"
}

horde::config::_json_value() {
	local file="$1"
	local key="$2"

	jq -r ".$key" "$file"
}

horde::config::_json_array() {
	local file="$1"
	local key="$2"

	if jq -e 'has("'"$key"'")' $file > /dev/null; then
		jq -r ".$key"' | join("\n")' "$file"
	fi
}

