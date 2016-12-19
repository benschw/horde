build: fliglio mysql rabbitmq chinchilla

fliglio:
	docker build -t benschw/horde-fliglio ./fliglio/
	docker build -t benschw/horde-fliglio-nginx ./fliglio-nginx/
	docker build -t benschw/horde-fliglio-fpm ./fliglio-fpm/


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



.PHONY: fliglio mysql rabbitmq chinchilla
