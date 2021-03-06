SHELL := bash
.ONESHELL:
#.SILENT:
.SHELLFLAGS := -eu -o pipefail -c
#.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
APP_NAME ?= $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

.PHONY: help
help:
>	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: publish-sem-rel
publish-sem-rel:
> git push origin master
> semantic-release publish

.PHONY: build
build:
#> @docker image prune -f
> docker buildx use wearep3r
> docker buildx build --platform linux/amd64 --build-arg BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION=$(shell git rev-parse --short HEAD) --build-arg VCS_REF=$(shell git rev-parse --short HEAD) -t wearep3r/docker:latest --load .

.PHONY: push
push:
#> @docker image prune -f
> docker push wearep3r/docker:latest


.PHONY: dev
dev: .SHELLFLAGS = ${DOCKER_SHELLFLAGS}
dev: SHELL := docker
dev:
> @dev