#!/bin/bash


pbio::get_plugin_path() {
	local plugin_path="$(config::get_horde_home)/plugins"

	if [ ${HORDE_PLUGIN_PATH+x} ]; then
		plugin_path=$HORDE_PLUGIN_PATH
	fi

	echo $plugin_path
}

pbio::get_horde_config_path() {
	echo "$(config::get_horde_home)/config.json"
}
pbio::get_horde_config() {
	if [ -e "$(pbio::get_horde_config_path)" ]; then
		cat "$(pbio::get_horde_config_path)"
	fi
}
pbio::set_horde_config() {
	local new_cfg="$1"
	echo $1 | jq . > "$(pbio::get_horde_config_path)"
}
pbio::get_pb_path() {
	echo "$(config::get_horde_home)/plugin-bundles"
}
pbio::get_pb_repo_path() {
	echo "$(config::get_horde_home)/repo"
}
pbio::get_pb_repo_cache_path() {
	echo "$(pbio::get_pb_repo_path)/plugins.cache"
}
pbio::get_pb_repo_config() {
	cat "$(pbio::get_pb_repo_cache_path)"
}
pbio::get_pb_install_path() {
	echo "$(pbio::get_plugin_path)/bundles"
}
