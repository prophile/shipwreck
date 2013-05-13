TO=nowhere

all: build/index.html build/shipwreck-version

ready: all deps

deps: obj/deps/bacon.js obj/deps/bootstrap.js obj/deps/jquery.js obj/deps/bootstrap.css

obj/deps:
	mkdir -p $@

obj/deps/bacon.js: obj/deps
	curl -o $@ 'https://raw.github.com/raimohanska/bacon.js/master/dist/Bacon.js'

obj/deps/bootstrap.css: obj/deps/bootstrap.zip
	unzip -p $< bootstrap/css/bootstrap.min.css > $@

obj/deps/bootstrap.js: obj/deps/bootstrap.zip
	unzip -p $< bootstrap/js/bootstrap.min.js > $@

obj/deps/bootstrap.zip: obj/deps
	curl -o $@ 'http://twitter.github.io/bootstrap/assets/bootstrap.zip'

obj/deps/jquery.js: obj/deps
	curl -o $@ 'http://code.jquery.com/jquery-2.0.0.min.js'

build/shipwreck-version:
	git describe --always > $@

build/index.html:
	touch $@

clean:
	rm -rf build
	rm -rf obj

install:
ifeq ($(TO),nowhere)
	@echo "No install target specified. Use make install TO=/path"
	@exit 1
else
	@if [ -e $(TO) -a ! -e $(TO)/shipwreck-version ]; \
	  then \
	    echo "Target exists and is not a previous install."; \
	    echo "If you mean to replace it, remove it first."; \
	    exit 1; \
	fi
	rm -rf $(TO)
	cp -Rf build $(TO)
	find $(TO) -type d | xargs chmod 755
	find $(TO) -type f | xargs chmod 644
endif

.PHONY: all ready deps clean install

