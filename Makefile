PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help
.PHONY: help build tester test

help:
	@printf '%s\n' \
	  'make build    Build your Redis implementation' \
	  'make tester   Build the pinned official CodeCrafters tester' \
	  'make test     Build both, then test every stage in ci/stages.txt'

build:
	cmake -S "$(PROJECT_ROOT)" -B "$(PROJECT_ROOT)/build" -DCMAKE_BUILD_TYPE=Debug
	cmake --build "$(PROJECT_ROOT)/build"

tester:
	sh "$(PROJECT_ROOT)/ci/fetch-tester.sh"
	mkdir -p "$(PROJECT_ROOT)/build"
	cd "$(PROJECT_ROOT)/vendor/redis-tester" && go build -o "$(PROJECT_ROOT)/build/redis-tester" ./cmd/tester

test: build tester
	sh "$(PROJECT_ROOT)/ci/run-tests.sh"
