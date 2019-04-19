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
		plugin_path="$HOME/.horde/plugins"
	fi

	if [ ${HORDE_PLUGIN_PATH+x} ]; then
		plugin_path=$HORDE_PLUGIN_PATH
	fi

	echo ${plugin_path}
}

# util::split_and_index
# parameters:
#		string			-		The string to split.
#		delimiter		-		The delimiter to split at.
#		index				-		The index to return.
#
# Given parameters string, delimiter, index
# splits string at delimiter and returns the part at
# the zero-based index.
util::split_and_index() {
	local string="$1"
	local delimiter="$2"
	local index="$3"
	# IFS sets the delimiter. read then splits it.
	# Results in an array in PARTS
  IFS=${delimiter}
  read -ra PARTS <<< "${string}"
  echo ${PARTS[${index}]}
}
