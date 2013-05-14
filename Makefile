TO=nowhere
MODULES=utils keyboard constants gamestate save gridview mapgen command hello historystep
MODE=debug

all: build/index.html build/shipwreck-version build/wreck.js build/style.css build/constants.json build/spritesheet.png build/favicon.ico

ready: all deps

serve:
	@cd build ; python3 -m http.server 51428

build/favicon.ico: sprites.png
	touch $@

build/spritesheet.png: sprites.png
	@mkdir -p build
	cat $^ > $@

build/constants.json: constants.json
	@mkdir -p build
	cat $^ > $@

build/style.css: obj/deps/bootstrap.css
	cat $^ > $@

build/wreck.js: obj/deps/jquery.js obj/deps/bootstrap.js obj/deps/typedarray.js obj/deps/simplex.js obj/deps/bacon.js obj/deps/underscore.js $(MODULES:%=obj/scripts/%.js)
	@mkdir -p build
ifeq ($(MODE),debug)
	cat $^ > $@
else
	uglifyjs -o $@ -m -c --screw-ie8 $^
endif

obj/scripts/%.js: src/%.coffee obj/scripts
	coffee --print $< > $@

deps: obj/deps/bacon.js obj/deps/bootstrap.js obj/deps/jquery.js obj/deps/bootstrap.css

obj/scripts: Makefile
	mkdir -p $@

obj/deps: Makefile
	mkdir -p $@

obj/deps/typedarray.js: obj/deps
	curl -o $@ 'http://www.calormen.com/polyfill/typedarray.js'

obj/deps/simplex.js: obj/deps
	curl -o $@ 'https://raw.github.com/jwagner/simplex-noise.js/master/simplex-noise.js'

obj/deps/underscore.js: obj/deps
	curl -o $@ 'http://underscorejs.org/underscore-min.js'

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
	@mkdir -p build
	git describe --always > $@

build/index.html: index.html
	@mkdir -p build
	cp $< $@

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

.PHONY: all ready deps clean install serve

