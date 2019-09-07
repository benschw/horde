#!/bin/bash


pb::_get_pb_desc() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"].description"
}
pb::_get_pb_vcs() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"].vcs"
}
pb::_get_pb_relpath() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"].path"
}
pb::_get_pb_plugins() {
	local name="$1"
	pb::_get_pb_drivers "$name"
	pb::_get_pb_services "$name"
	pb::_get_pb_initializers "$name"
}
pb::_get_pb_drivers() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"] | select(.drivers != null) | .drivers[]"
}
pb::_get_pb_services() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"] | select(.services != null) | .services[]"
}
pb::_get_pb_initializers() {
	local name="$1"
	local repo_index=$(pb_cfg::get_pb_repo_config)
	echo "${repo_index}" | jq -r ".[\"${name}\"] | select(.initializers != null) | .initializers[]"
}

pb::_install_pb() {
	local name="$1"
	local src_path="$(pb_cfg::get_pb_path)/${name}$(pb::_get_pb_relpath $name)"
	local install_path="$(pb_cfg::get_pb_install_path)/${name}"
	local lock="$(pb_cfg::get_pb_path)/${name}.lock"

	ln -sfh "${src_path}" "${install_path}"

	echo "${install_path}" > "${lock}"
}
pb::_uninstall_pb() {
	local name="$1"
	local pb_path=$(pb_cfg::get_pb_path)
	local lock="${pb_path}/${name}.lock"

	if [ -e "$lock" ]; then
		echo $(cat "${lock}")
		rm $(cat "${lock}")
		rm "${lock}"
	fi
}
