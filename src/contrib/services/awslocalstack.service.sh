#!/bin/bash

services::awslocalstack() {
	local ip=$(net::bridge_ip)
	local name="awslocalstack"

	service::ensure_running consul || return 1
	net::configure_hosts "awsls-ui.horde" || return 1
	net::configure_hosts "awsls-sns.horde" || return 1
	net::configure_hosts "awsls-sqs.horde" || return 1
	net::configure_hosts "awsls-dynamo.horde" || return 1
	net::configure_hosts "awsls-s3.horde" || return 1
	net::configure_hosts "awsls-cloudwatch.horde" || return 1
	net::configure_hosts "awsls-lambda.horde" || return 1

	container::call run \
		-d \
		-P \
		-e "SERVICE_8080_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_8080_TAGS=urlprefix-awsls-ui.horde/,service" \
		-e "SERVICE_4569_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4569_TAGS=urlprefix-awsls-dynamo.horde/,service" \
		-e "SERVICE_4572_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4572_TAGS=urlprefix-awsls-s3.horde/,service" \
		-e "SERVICE_4574_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4574_TAGS=urlprefix-awsls-lambda.horde/,service" \
		-e "SERVICE_4575_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4575_TAGS=urlprefix-awsls-sns.horde/,service" \
		-e "SERVICE_4576_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4582_TAGS=urlprefix-awsls-cloudwatch.horde/,service" \
		-e "SERVICE_4582_CHECK_SCRIPT=\"true\"" \
		-e "SERVICE_4576_TAGS=urlprefix-awsls-sqs.horde/,service" \
		--name $name \
		--dns $ip \
		localstack/localstack || return 1

	sleep 5
}
