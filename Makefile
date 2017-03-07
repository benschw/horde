default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat src/common.sh \
		src/config.sh \
		src/cli.sh \
		src/pluginmgr.sh \
		src/main.sh \
		> build/horde
	chmod +x build/horde

install:
	cp build/horde /usr/local/bin/horde
	mkdir -p $(HOME)/.horde/plugins/
	cp services/*.sh $(HOME)/.horde/plugins/
	cp drivers/*.sh $(HOME)/.horde/plugins/


.PHONY: build
