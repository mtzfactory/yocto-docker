SHELL := /bin/bash

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
	source poky/oe-init-build-env; \
	bitbake -c fetchall gumstix-console-image

.PHONY: build
build: check-env no-root-user
	source poky/oe-init-build-env; \
	bitbake gumstix-console-image

sdk: check-env no-root-user
	source poky/oe-init-build-env; \
	bitbake -c populate_sdk gumstix-console-image
