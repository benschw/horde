build: fliglio mysql rabbitmq chinchilla

alpine-php:
	docker build -t alpine-php ./alpine-php

fliglio:
	docker build -t benschw/horde-fliglio ./fliglio/

mysql:
	docker build -t benschw/horde-mysql ./mysql/

rabbitmq:
	docker build -t benschw/horde-rabbitmq ./rabbitmq/

chinchilla:
	docker build -t benschw/horde-chinchilla ./chinchilla/


publish:
	docker push benschw/horde-fliglio
	docker push benschw/horde-mysql
	docker push benschw/horde-rabbitmq
	docker push benschw/horde-chinchilla

.PHONY: fliglio mysql rabbitmq chinchilla alpine-php
