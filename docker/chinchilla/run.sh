#!/bin/bash


read -r -d '' conn_cfg << EOF
user: guest
password: guest
vhost: /
servicename: rabbitmq
EOF


curl -s -X PUT http://${CONSUL_PORT_8500_TCP_ADDR}:8500/v1/kv/chinchilla/connection.yaml -d "$conn_cfg"

CONSUL_HTTP_ADDR="${CONSUL_PORT_8500_TCP_ADDR}:8500" /bin/chinchilla -log-path /dev/stdout
