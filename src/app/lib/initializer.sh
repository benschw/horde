#!/bin/bash


initializer::init() {
	local name="$1"

	local initializer="initializers::${name}"

	if ! util::func_exists "${initializer}" ; then
		io::err "initializer $name not found"
		return 1
	fi

	initializers::${name} || return 1
}
