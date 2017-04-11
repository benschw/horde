#!/bin/bash

#services::aws::cli s3api create-bucket --bucket=horde

services::aws::cli() {
	args=("$@")
	
	local CMD="aws --endpoint-url=http://\${S3_PORT_9000_TCP_ADDR}:9000 ${args[@]}"

	docker run -it \
		--link s3:s3 \
		-e AWS_ACCESS_KEY_ID=horde \
		-e AWS_SECRET_ACCESS_KEY=horde_secret \
		-e AWS_DEFAULT_REGION=us-west-1 \
		garland/aws-cli-docker \
		sh -c "${CMD}"
}
