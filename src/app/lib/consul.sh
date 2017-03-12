#!/bin/bash

consul::register() {
	local name="$1"
	local host="$2"
	local port="$3"
	local ip=$(dig +short "${host}")
	local hostname="${name}.horde"
	echo "setting $name"
	
	net::configure_hosts "${hostname}" || return 1
	

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
		util::msg "problem deregistering ${name} from consul"
		return 1
	fi
}



consul::deregister() {
	local name="$1"

	if ! curl -s -X POST "http://consul.horde/v1/agent/service/deregister/${name}" ; then
		util::msg "problem registering ${name} in consul"
		return 1
	fi
}

