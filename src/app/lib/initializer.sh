#!/bin/bash

initializer::assert_installed() {
	local names=("$@")
	local name=""

	for name in "${names[@]}"; do
		if ! util::func_exists "initializers::${name}"; then
			io::err "Initializer '${name}' not installed"
			plugin_mgr::find "$name"
			return 1
		fi
	done
}

initializer::init() {
	local name="$1"

	local initializer="initializers::${name}"

	initializer::assert_installed "$name" || return 1

	initializers::${name} || return 1
}
