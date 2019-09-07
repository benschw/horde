#!/bin/bash


pb_cfg::get_plugin_path() {
	local plugin_path="$(config::get_horde_home)/plugins"

	if [ ${HORDE_PLUGIN_PATH+x} ]; then
		plugin_path=$HORDE_PLUGIN_PATH
	fi

	echo $plugin_path
}

pb_cfg::get_horde_config_path() {
	echo "$(config::get_horde_home)/config.json"
}
pb_cfg::get_horde_config() {
	if [ -e "$(pb_cfg::get_horde_config_path)" ]; then
		cat "$(pb_cfg::get_horde_config_path)"
	fi
}
pb_cfg::set_horde_config() {
	local new_cfg="$1"
	echo $1 | jq . > "$(pb_cfg::get_horde_config_path)"
}
pb_cfg::get_pb_path() {
	echo "$(config::get_horde_home)/plugin-bundles"
}
pb_cfg::get_pb_repo_path() {
	echo "$(config::get_horde_home)/repo"
}
pb_cfg::get_pb_repo_cache_path() {
	echo "$(pb_cfg::get_pb_repo_path)/plugins.cache"
}
pb_cfg::get_pb_repo_config() {
	cat "$(pb_cfg::get_pb_repo_cache_path)"
}
pb_cfg::get_pb_install_path() {
	echo "$(pb_cfg::get_plugin_path)/bundles"
}
