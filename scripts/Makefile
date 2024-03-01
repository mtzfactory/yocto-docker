SHELL := /bin/bash

export TEMPLATECONF=meta-gumstix-extras/conf

.PHONY: check-env build

ifneq (,$(wildcard ./yocto.env))
	include yocto.env
	export
endif

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

check-env: guard-TEMPLATECONF
	@echo "Checking env variables"

no-root-user:
ifeq ($(shell id -u), 0)
	@echo "You can't be root to perform this action"
	@exit 1
endif

fetch-all: check-env no-root-user
	. poky/oe-init-build-env; \
	cp ../local.conf conf/local.conf; \
	bitbake -c fetchall gumstix-console-image

build: check-env no-root-user
	. poky/oe-init-build-env; \
	bitbake gumstix-console-image

sdk: check-env no-root-user
	. poky/oe-init-build-env; \
	bitbake -c populate_sdk gumstix-console-image
