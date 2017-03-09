#!/bin/bash

horde::cli::register() {
	local name="$1"
	local host="$2"
	local port="$3"
	local ip=$(dig +short "${host}")
	local hostname="${name}.horde"
	echo "setting $name"
	
	horde::cfg_hostname "${hostname}" || return 1
	

	read -r -d '' svc_def << EOF
{
  "ID": "${name}",
  "Name": "${name}",
  "Address": "${ip}",
  "Port": $port,
  "Tags":["urlprefix-${hostname}/", "external-app"],
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



horde::cli::deregister() {
	local name="$1"

	if ! curl -s -X POST "http://consul.horde/v1/agent/service/deregister/${name}" ; then
		horde::err "problem registering ${name} in consul"
		return 1
	fi
}
