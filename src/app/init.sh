#!/bin/bash


plugin_path=$HOME/.horde/plugins

if [ ${HORDE_PLUGIN_PATH+x} ]; then
	plugin_path=$HORDE_PLUGIN_PATH
fi


for f in $(find "${plugin_path}" -name "*.service.sh"); do
	source $f
done

for f in $(find "${plugin_path}" -name "*.driver.sh"); do
	source $f
done



main "$@" || exit 1

