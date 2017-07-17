default: build

clean:
	rm -rf build

build: clean
	mkdir -p build build/core build/contrib
	cat src/app/lib/* \
		src/app/cli.sh \
		src/app/config.sh \
		src/app/main.sh \
		> build/horde
	chmod +x build/horde
	cp src/plugins/services/*.sh build/core/
	cp src/plugins/drivers/*.sh build/core/
	cp src/contrib/services/*.sh build/contrib/
	cp src/contrib/drivers/*.sh build/contrib/



dist: build
	mkdir -p build/dist
	gzip < build/horde > build/dist/horde_latest.gz
	tar -C build -czvf build/dist/horde-plugins-core_latest.tar.gz core
	tar -C build -czvf build/dist/horde-plugins-contrib_latest.tar.gz contrib
	cp build/dist/horde_latest.gz build/dist/horde_$(shell git describe --tags).gz
	cp build/dist/horde-plugins-core_latest.tar.gz build/dist/horde-plugins-core_$(shell git describe --tags).tar.gz
	cp build/dist/horde-plugins-contrib_latest.tar.gz build/dist/horde-plugins-contrib_$(shell git describe --tags).tar.gz

ci: dist
	mkdir -p build/latest build/release
	mv build/dist/*latest* build/latest/
	mv build/dist/* build/release/

install:
	cp build/horde /usr/local/bin/horde
	mkdir -p $(HOME)/.horde/plugins/core/
	cp build/core/*.sh $(HOME)/.horde/plugins/core/

contrib-install:
	mkdir -p $(HOME)/.horde/plugins/contrib
	cp build/contrib/*.sh $(HOME)/.horde/plugins/contrib/


.PHONY: build
