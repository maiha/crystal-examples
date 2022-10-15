SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

export LC_ALL=C
export UID = $(shell id -u)
export GID = $(shell id -g)

BUILD := docker compose run --rm build shards build --link-flags "-static"

.PHONY : crystal-examples-dev
crystal-examples-dev:
	$(BUILD) crystal-examples-dev

.PHONY : release
release:
	$(BUILD) crystal-examples --release

.PHONY : up
up:
	docker compose up -d

.PHONY : down
down:
	docker compose down -v --remove-orphans

.PHONY : rebuild
rebuild:
	docker compose build --no-cache

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
	docker compose run --rm build crystal spec -v --fail-fast


.PHONY : check_version_mismatch
check_version_mismatch: shard.yml README.md
	diff -w -c <(grep version: README.md) <(grep ^version: shard.yml)

VERSION=
CURRENT_VERSION=$(shell git tag -l | sort -V | tail -1 | sed -e 's/^v//')
GUESSED_VERSION=$(shell git tag -l | sort -V | tail -1 | sed -e 's/^v//' | awk 'BEGIN { FS="." } { $$3++; } { printf "%d.%d.%d", $$1, $$2, $$3 }')

.PHONY : version
version: README.md
	@if [ "$(VERSION)" = "" ]; then \
	  echo "ERROR: specify VERSION as bellow. (current: $(CURRENT_VERSION))";\
	  echo "  make version VERSION=$(GUESSED_VERSION)";\
	else \
	  sed -i -e 's/^version: .*/version: $(VERSION)/' shard.yml ;\
	  sed -i -e 's/^    version: [0-9]\+\.[0-9]\+\.[0-9]\+/    version: $(VERSION)/' $< ;\
	  echo git commit -a -m "'$(COMMIT_MESSAGE)'" ;\
	  git commit -a -m 'version: $(VERSION)' ;\
	  git tag "v$(VERSION)" ;\
	fi

.PHONY : bump
bump:
	make version VERSION=$(GUESSED_VERSION) -s
