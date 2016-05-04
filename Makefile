default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat common.sh services.sh fliglio.sh cli.sh > build/horde
	chmod +x build/horde

install:
	cp build/horde /usr/local/bin/horde


.PHONY: build
