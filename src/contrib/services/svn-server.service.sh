#!/bin/bash

# https://medium.com/@elle.florio/the-svn-dockerization-84032e11d88d#.bafh3otmh
services::svn-server() {
	local ip=$(net::bridge_ip)
	local hostname="svn-server.horde"

    service::ensure_running consul || return 1
	container::delete_stopped svn-server || return 1
	net::configure_hosts "${hostname}" || return 1

	container::call run -d \
		-p 80 \
		-p 3690:3690 \
		--name=svn-server \
		-e "SERVICE_80_CHECK_HTTP=/svnadmin/settings.php" \
		-e "SERVICE_80_TAGS=urlprefix-${hostname}/,service" \
		--dns ${ip} \
		elleflorio/svn-server:latest || return 1
	
	sleep 2

	services::svn-server::horde_user
	services::svn-server::horde_repo

}

services::svn-server::horde_user() {
	container::call exec -t svn-server htpasswd -b /etc/subversion/passwd horde changeme

	# allow rw access
	container::call exec -t svn-server sh -c "echo 'horde = rw' >> /etc/subversion/subversion-access-control"
}

services::svn-server::horde_repo() {
	container::call exec -t svn-server sh -c "cd /home/svn/; svnadmin create horde; chown -R apache:apache /home/svn/horde"
}
