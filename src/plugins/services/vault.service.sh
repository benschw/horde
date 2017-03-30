#!/bin/bash

services::vault() {
	local ip=$(net::bridge_ip)
	container::delete_stopped vault || return 1

	container::call run \
		-d \
		-p 8200:8200 \
		--name vault \
		--cap-add=IPC_LOCK \
		-e VAULT_DEV_ROOT_TOKEN_ID=horde \
		--dns ${ip} \
		vault:0.6.5 || return 1
	sleep 3

	docker run -it \
		--rm \
		--link vault:vault \
		-e VAULT_TOKEN=horde \
		vault:0.6.5  \
		/bin/sh -c 'VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200 vault auth-enable userpass' \
		|| return 1

	docker run -it \
		--rm \
		--link vault:vault \
		-e VAULT_TOKEN=horde \
		vault:0.6.5  \
		/bin/sh -c 'VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200 vault write auth/userpass/users/horde \
			password=horde \
			policies=admins' \
		|| return 1

	docker run -it \
		--rm \
		--link vault:vault \
		-e VAULT_TOKEN=horde \
		vault:0.6.5  \
		/bin/sh -c 'echo '\''{"path":{"*":{"policy":"sudo"}}}'\'' | \
		    VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200 vault policy-write admins -' \
		|| return 1
}

services::vault::provide_vault_creds() {
    local name="$1"

    docker run -it \
		--rm \
		--link vault:vault \
		-v `pwd`/.vault/creds:/mnt/creds \
		-e VAULT_TOKEN=horde \
		-e APP_NAME="${name}" \
		vault:0.6.5  \
		/bin/sh -c 'apk -v --update --no-cache add jq; \
					export VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200; \
					vault auth-enable approle; \
					echo '\''{"path":{"secret/'\''$APP_NAME'\''":{"policy":"write"}}}'\'' | \
					vault policy-write $APP_NAME -; \
					vault write auth/approle/role/$APP_NAME bind_secret_id=true token_ttl=5m token_max_ttl=10m policies=$APP_NAME; \
					vault read -format=json auth/approle/role/$APP_NAME/role-id | jq -r .data.role_id > roleId.txt; \
					vault write -f -format=json auth/approle/role/$APP_NAME/secret-id | jq -r .data.secret_id > secretId.txt; \
					mv *.txt /mnt/creds;' \
		|| return 1

    #Add AppRole credentials to environment variables file.
    sed -i '' '/^VAULT_ROLE_ID/d' src/config/dev-local.env;
    sed -i '' '/^VAULT_SECRET_ID/d' src/config/dev-local.env;
    echo -n 'VAULT_ROLE_ID=' >> src/config/dev-local.env && cat .vault/creds/roleId.txt >> src/config/dev-local.env;
    echo -n 'VAULT_SECRET_ID=' >> src/config/dev-local.env && cat .vault/creds/secretId.txt >> src/config/dev-local.env;
}

services::vault::write_vault_secrets() {
    local name="$1"

	docker run -it \
		--rm \
		--link vault:vault \
		-v `pwd`/.vault/secrets:/mnt/secrets \
		-e VAULT_TOKEN=horde \
		-e APP_NAME="${name}" \
		vault:0.6.5  \
		/bin/sh -c 'export VAULT_ADDR=http://$VAULT_PORT_8200_TCP_ADDR:8200; \
					vault write secret/$APP_NAME `cat /mnt/secrets/secrets.txt`' \
		|| return 1
}