SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

export LC_ALL=C
export UID = $(shell id -u)
export GID = $(shell id -g)

BUILD := docker-compose run --rm build shards build --link-flags "-static"

.PHONY : crystal-examples-dev
crystal-examples-dev:
	$(BUILD) crystal-examples-dev

.PHONY : release
release:
	$(BUILD) crystal-examples --release

.PHONY : rebuild
rebuild:
	docker-compose build --no-cache build

native/crystal-examples-dev:
	shards build --link-flags "-static" crystal-examples-dev

native/crystal-examples:
	shards build --link-flags "-static" crystal-examples --release

.PHONY : install
install: release
	cp -p bin/crystal-examples /usr/local/bin/

.PHONY : ci
ci: crystal-examples-dev spec

.PHONY : spec
spec:
	docker-compose run --rm build crystal spec -v --fail-fast
