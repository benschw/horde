#/bin/bash

horde::json::value() {
	local file="$1"
	local key="$2"

	jq -r ".$key" "$file"
}

horde::json::array() {
	local file="$1"
	local key="$2"

	if jq -e 'has("'"$key"'")' $file > /dev/null; then
		jq -r ".$key"' | join("\n")' "$file"
	fi
}

