SHELL = /bin/bash

.SHELLFLAGS = -o pipefail -c

export LC_ALL=C
export UID = $(shell id -u)
export GID = $(shell id -g)

.PHONY : all
all: upgrade web

.PHONY : upgrade
upgrade:
	@crystal-examples setup .

.PHONY : web
web:
	@docker compose run --rm crystal ./crystal-examples web

.PHONY : crystal
crystal:
	@docker compose run --rm crystal bash -c "cd crystal && make"

.PHONY : console
console:
	@docker compose run --rm crystal bash

.PHONY : console-root
console-root:
	@(unset UID; unset GID; docker compose run --rm crystal bash)
