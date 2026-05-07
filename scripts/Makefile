SHELL := /bin/bash
IMAGE ?= gumstix-console-image

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

deploy:
	@cp /usr/local/share/yocto-overo/local.conf build/conf/local.conf
	@cp /usr/local/share/yocto-overo/bblayers.conf build/conf/bblayers.conf
	@cp -r /usr/local/share/yocto-overo/poky/. poky/
	
.PHONY: build
build: check-env no-root-user deploy
	source poky/oe-init-build-env; \
	bitbake ${IMAGE}

fetch-all: check-env no-root-user deploy
	source poky/oe-init-build-env; \
	bitbake -c fetchall ${IMAGE}

fetch-jdk: check-env no-root-user deploy
	source poky/oe-init-build-env; \
	bitbake -c fetch openjdk-8 openjdk-8-native

sdk: check-env no-root-user deploy
	source poky/oe-init-build-env; \
	bitbake -c populate_sdk ${IMAGE}
