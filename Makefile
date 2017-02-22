default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat src/common.sh src/services.sh src/config.sh src/cli.sh src/drivermgr.sh src/main.sh > build/horde
	chmod +x build/horde

install:
	cp build/horde /usr/local/bin/horde
	mkdir -p $(HOME)/.horde/drivers/
	cp drivers/*.sh $(HOME)/.horde/drivers/


.PHONY: build
