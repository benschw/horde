default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat src/app/lib/net.sh \
		src/app/lib/hosts.sh \
		src/app/lib/container.sh \
		src/app/lib/service.sh \
		src/app/lib/driver.sh \
		src/app/util.sh \
		src/app/config.sh \
		src/app/cli/help.sh \
		src/app/cli/run.sh \
		src/app/cli/consul_register.sh \
		src/app/main.sh \
		src/app/init.sh \
		> build/horde
	chmod +x build/horde

install:
	cp build/horde /usr/local/bin/horde
	mkdir -p $(HOME)/.horde/plugins/core/
	cp src/plugins/services/*.sh $(HOME)/.horde/plugins/core/
	cp src/plugins/drivers/*.sh $(HOME)/.horde/plugins/core/

contrib-install:
	mkdir -p $(HOME)/.horde/plugins/contrib
	cp src/contrib/services/*.sh $(HOME)/.horde/plugins/contrib/
	cp src/contrib/drivers/*.sh $(HOME)/.horde/plugins/contrib/


.PHONY: build
