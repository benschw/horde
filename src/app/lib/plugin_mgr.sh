#!/bin/bash

plugin_mgr::load() {
	# Call util::get_plugin_path to maintain backwards compatibility.
	local plugin_path=$(util::get_plugin_path "$1")

	for f in $(find -L "${plugin_path}" -name "*.initializer.sh"); do
		source $f
	done

	for f in $(find -L "${plugin_path}" -name "*.service.sh"); do
		source $f
	done

	for f in $(find -L "${plugin_path}" -name "*.driver.sh"); do
		source $f
	done
}
