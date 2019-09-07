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
plugin_mgr::add-repo() {
	local repo="$1"
	if [ -z ${1+x} ]; then
		io::err "must provide a repo address to add"
		return 1
	fi
	local cfg=$(pb_cfg::get_horde_config)
	
	if [[ "$(echo $cfg | jq ".plugin_repos | index( \"$repo\" )")" != "null" ]]; then
		io::err "Repo $repo already exists"
		return 1
	fi


	local cfg_str=""

	for r in $(echo $cfg | jq  .plugin_repos[]); do
		cfg_str="${cfg_str}$r, "
	done
	local new_cfg="{\"plugin_repos\": [ ${cfg_str} \"$repo\" ]}"
	pb_cfg::set_horde_config "$new_cfg"

	printf "$repo added. update to start using:\n  horde pb update\n"

}
plugin_mgr::update() {
	local repo_path=$(pb_cfg::get_pb_repo_path)
	local cfg=$(pb_cfg::get_horde_config)
	local cache_path=$(pb_cfg::get_pb_repo_cache_path)
	local current_wd=$(pwd)

	rm -rf "${repo_path}"
	mkdir -p "${repo_path}"

	cd "${repo_path}"
	
	for repo in $(echo $cfg | jq -r .plugin_repos[]); do
		if ! git clone "${repo}"; then
			io::err "problem updating horde plugin repo $repo. Aborting."
			return 1
		fi
	done;
	
	cd $current_wd

	jq -s 'reduce .[] as $item ({}; . * $item)' \
		$(find -L "${repo_path}" -name "plugins.json") \
		> "${cache_path}"

}

plugin_mgr::list() {
	local pb_path=$(pb_cfg::get_pb_path)
	local cache_path=$(pb_cfg::get_pb_repo_cache_path)

	if [[ "$1" == "all" ]]; then
		for pb in $(cat $cache_path | jq -r 'keys'[]); do
			plugin_mgr::info "$pb"
		done;
	else
		for lock in $(ls $pb_path/*.lock); do
			plugin_mgr::info "$(basename $lock '.lock')"
		done
	fi
}
plugin_mgr::info() {
	local pb="$1"

	if [ -z ${1+x} ]; then
		io::err "plugin-bundle name missing"
		return 1
	fi

	echo "$pb - $(pb::_get_pb_desc $pb)"
	echo "  Drivers: $(pb::_get_pb_drivers $pb | tr '\n' ' ')"
	echo "  Services: $(pb::_get_pb_services $pb | tr '\n' ' ')"
	echo "  Initializers: $(pb::_get_pb_initializers $pb | tr '\n' ' ')"
}

plugin_mgr::install() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		io::err "must specify a plugin-bundle name"
		return 1
	fi

	local current_wd=$(pwd)
	local install_path=$(pb_cfg::get_pb_install_path)
	local pb_path=$(pb_cfg::get_pb_path)

	for name in "${names[@]}"; do
		if [ -e "${pb_path}/$name" ]; then
			io::err "Plugin-bundle ${name} already installed. Upgrade with \`horde pb upgrade ${name}\`"
			return 1
		fi
	done	

	for name in "${names[@]}"; do
		local pb_vcs=$(pb::_get_pb_vcs "${name}")

		printf "\n"
		mkdir -p "${pb_path}"
		mkdir -p "${install_path}"

		cd $pb_path
		if ! git clone $pb_vcs $name; then
			io::err "Problem installing $name. Aborting"
			return 1
		fi
		cd $current_wd

		pb::_install_pb "$name"

		printf "> ${name} installed\n"
	done
}

plugin_mgr::upgrade() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		io::err "must specify a plugin-bundle name"
		return 1
	fi
	local current_wd=$(pwd)
	local install_path=$(pb_cfg::get_pb_install_path)
	local pb_path=$(pb_cfg::get_pb_path)

	if [[ "$1" == "all" ]]; then
		names=()
		for lock in $(ls $pb_path/*.lock); do
			names+=( $(basename $lock '.lock') )
		done
	fi


	for name in "${names[@]}"; do
		if [ ! -e "${pb_path}/$name" ]; then
			io::err "Plugin-bundle ${name} not installed. Install with \`horde pb install ${name}\`"
			return 1
		fi
	done	

	for name in "${names[@]}"; do
		printf "\n"

		cd $pb_path/$name
		if ! git pull; then
			io::err "Problem upgrading $name. Aborting"
			return 1
		fi
		cd $current_wd
	
		pb::_uninstall_pb "$name"
		pb::_install_pb "$name"

		printf "> ${name} upgraded\n"
	done
}
plugin_mgr::uninstall() {
	local names=("$@")
	if [ "${#names[@]}" -eq 0 ]; then
		io::err "must specify a plugin-bundle name"
		return 1
	fi

	local pb_path=$(pb_cfg::get_pb_path)

	if [[ "$1" == "all" ]]; then
		names=()
		for lock in $(ls $pb_path/*.lock); do
			names+=( $(basename $lock '.lock') )
		done
	fi

	for name in "${names[@]}"; do
		if [ ! -e "${pb_path}/$name" ]; then
			io::err "Plugin-bundle ${name} not installed."
			return 1
		fi
	done	

	for name in "${names[@]}"; do
		printf "\n"

		pb::_uninstall_pb "$name"
		rm -rf "${pb_path}/${name}"

		printf "> ${name} removed\n"
	done
}

plugin_mgr::find() {
	local name="$1"

	local cache_path=$(pb_cfg::get_pb_repo_cache_path)

	for pb in $(cat $cache_path | jq -r 'keys'[]); do
		for p in $(pb::_get_pb_plugins $pb); do
			if [ "${name}" == "${p}" ]; then
				echo "plugin $name found in plugin-bundle $pb. Install with:"
				echo "   horde pb install $pb"
				return 0
			fi
		done
	done
	echo "no plugin-bundle containing $name found"
	return 1
}

plugin_mgr::help() {
	echo "USAGE:"
	echo "    horde pb CMD [options]"
	echo
	echo "COMMANDS:"
	echo "    add-repo REPO_NAME           add plugin repo to horde config"
	echo "    update                       refresh local cache of registered plugin repos"
	echo "    list [option]                list all available plugins (option 'all' for available too)"
	echo "    info NAME                    get info about a plugin-bundle"
	echo "    install [name [name]]        install 1 or more plugin bundles"
	echo "    upgrade [name [name]]        upgrade 1 or more plugin bundles"
	echo "    uninstall [name [name]]      uninstall 1 or more plugin bundles"
	echo "    help                         display this help text and exit"
	echo
	echo "    (name refers to the plugin bundle name not the plugin's name)"
	echo
	echo "EXAMPLES:"
	echo "    horde pb add-repo git@github.com:benschw/horde.git"
	echo "    horde pb update"
	echo "    horde pb install contrib"
	echo
	echo "See https://github.com/benschw/horde/ for more details"
}
