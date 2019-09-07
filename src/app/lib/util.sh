#!/bin/bash

util::cmd_exists() {
	local cli="$1"

	command -v "$cli" >/dev/null 2>&1 || return 1
}

util::func_exists() {
	local f=$1

	if [ -n "$(type -t $f)" ] && [ "$(type -t $f)" = function ]; then
		return 0
	fi
	return 1
}

# util::get_plugin_path
# Parameters:
#		[optional] plugin_path		-	The plugin path to override if necessary.
#
# GIVEN no input
# AND HORDE_PLUGIN_PATH is unset or null
# THEN return $HOME/.horde/plugins
#
# GIVEN input
# AND HORDE_PLUGIN_PATH is unset or null
# THEN return input
#
# GIVEN no input
# AND HORDE_PLUGIN_PATH is set
# THEN return $HORDE_PLUGIN_PATH
#
# GIVEN input
# AND HORDE_PLUGIN_PATH is set
# THEN return $HORDE_PLUGIN_PATH
util::get_plugin_path() {
	local plugin_path="$1"
	# For backwards compatibility, only set the parameter
	# if the caller does not provide one.
	if [ -z ${plugin_path} ]; then
		plugin_path="$(pbio::get_plugin_path)"
	fi

	echo $plugin_path
}

