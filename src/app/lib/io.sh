#!/bin/bash


io::err() {
	echo $@ >&2
}

io::trace() {
	local i=0
	local stack=(${FUNCNAME[@]})
	unset stack[0]
	unset stack[0]

	for fcn in "${stack[@]}" ; do
		echo $i: $fcn >&2
		i=$((i+1))
	done
}

