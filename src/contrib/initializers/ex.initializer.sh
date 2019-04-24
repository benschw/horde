#!/bin/bash

initializers::ex() {
  local plugin_path=$(util::get_plugin_path)
  local ex_initializer_path=$(find -L "${plugin_path}" -name "ex.initializer.sh")
  local ex_template_path=$(dirname ${ex_initializer_path})/template
  local name=$(basename $(pwd))
  # Copy all the files under the template
  cp -r ${ex_template_path}/* .

  name=${name} eval "cat <<EOF
$(<horde.json.tpl)
EOF
  " 2> /dev/null > horde.json
  rm horde.json.tpl
}
