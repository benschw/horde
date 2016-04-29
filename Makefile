default: build

clean:
	rm -rf build

build: clean
	mkdir -p build
	cat common.sh services.sh fliglio.sh cli.sh > build/kdev
	chmod +x build/kdev

install:
	cp build/kdev /usr/local/bin/kdev


.PHONY: build
