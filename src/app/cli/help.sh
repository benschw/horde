#!/bin/bash


horde::cli::_get_usage() {
	echo "USAGE:"
	echo "    horde command [name]"
	echo
	echo "COMMANDS:"
	echo "    run          start up an app (requires horde.json)"
	echo "    logs [name]  follow the logs for a container (uses horde.json"
	echo "                 if a name isn't supplied)"
	echo "    stop [name]  stop a fliglio app (uses horde.json if a name"
	echo "                 isn't supplied)"
	echo "    restart      alias for stop and up (requires horde.json)"
	echo "    kill [name]  kill a fliglio app (uses horde.json if a name"
	echo "                 isn't supplied)"
	echo
	echo "    register name domain port    register an external service with consul"
	echo "    deregister name              deregister an external service"
	echo
	echo "CONFIG:"
	echo "    {"
	echo "        \"driver\": \"static\","
	echo "        \"name\": \"container-name\""
	echo "    }"
	echo
	echo "See https://github.com/benschw/horde/ for more details"
}


