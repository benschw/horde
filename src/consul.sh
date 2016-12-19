#!/bin/bash

horde::consul::has_tag() {
	local name="$1"
	local tag="$2"
	horde::consul::get_tags "$1" | grep "$tag" || return 1
}

horde::consul::get_tags() {
	local name="$1"
	local tags=$(curl -s "http://consul.horde/v1/agent/services" | jq -r ".[] | select(.Service | contains(\"${name}\")) | .Tags[]")
	echo $tags
}

horde::consul::register() {
	local name="$1"
	local ip="$2"
	local port="$3"
	local hostname="$4"

	read -r -d '' svc_def << EOF
{
  "ID": "${name}",
  "Name": "${name}",
  "Address": "${ip}",
  "Port": $port,
  "Tags":["urlprefix-${hostname}/", "horde-external-app"],
  "Check":{
    "script": "echo ok",
    "Interval": "5s",
    "timeout": "2s"
  }
}
EOF

	if ! curl -s -X PUT "http://consul.horde/v1/agent/service/register" -d "${svc_def}" ; then
		horde::err "problem deregistering ${name} from consul"
		return 1
	fi
		
}
horde::consul::deregister() {
	local name="$1"

	if ! curl -s -X POST "http://consul.horde/v1/agent/service/deregister/${name}" ; then
		horde::err "problem registering ${name} in consul"
		return 1
	fi
}
