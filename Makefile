default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat src/app/common.sh \
		src/app/lib/service.sh \
		src/app/config.sh \
		src/app/cli/cli.sh \
		src/app/cli/help.sh \
		src/app/cli/consul_register.sh \
		src/app/cli/up.sh \
		src/app/app.sh \
		src/app/main.sh \
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
