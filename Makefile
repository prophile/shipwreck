TO=nowhere

all: build/index.html build/shipwreck-version

build/shipwreck-version:
	git describe --always > $@

build/index.html:
	touch $@

clean:
	rm -f build

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

.PHONY: all clean install

