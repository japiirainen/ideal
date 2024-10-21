.PHONY: format
format:
	@treefmt

.PHONY: build
build:
	@cabal build all

.PHONY: run
run:
	@cabal run exe:ideal

.PHONY: lint
lint:
	@hlint bin
