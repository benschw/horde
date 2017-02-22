#!/bin/bash


driver_path=$HOME/.horde/drivers

if [ ${HORDE_DRIVER_PATH+x} ]; then
	driver_path=$HORDE_DRIVER_PATH
fi



for f in $(find "${driver_path}" -name "*.driver.sh"); do
	source $f
done

