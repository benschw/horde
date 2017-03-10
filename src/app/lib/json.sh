#/bin/bash

horde::json::value() {
	local key=$1

	jq -r ".$key" ./horde.json
}

horde::json::array() {
	local key=$1

	if jq -e 'has("'"$key"'")' ./horde.json > /dev/null; then
		jq -r ".$1"' | join("\n")' ./horde.json
	fi
}

