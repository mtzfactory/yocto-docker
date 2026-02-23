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
	@mkdir -p poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm
	@cp /usr/local/share/yocto-overo/raw2rgbpnm_git.bb \
	  poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb
	@mkdir -p poky/meta-gumstix-extras/recipes-devtools/ltrace
	@cp /usr/local/share/yocto-overo/ltrace_git.bbappend \
	  poky/meta-gumstix-extras/recipes-devtools/ltrace/ltrace_git.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-support/serial-utils
	@cp /usr/local/share/yocto-overo/serial-forward_git.bbappend \
	  poky/meta-gumstix-extras/recipes-support/serial-utils/serial-forward_git.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-core/packagegroups
	@cp /usr/local/share/yocto-overo/packagegroup-cli-tools.bbappend \
	  poky/meta-gumstix-extras/recipes-core/packagegroups/packagegroup-cli-tools.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-support/vim
	@cp /usr/local/share/yocto-overo/vim_7.4.258.bbappend \
	  poky/meta-gumstix-extras/recipes-support/vim/vim_7.4.258.bbappend
	@cp /usr/local/share/yocto-overo/bblayers.conf build/conf/bblayers.conf
	@mkdir -p poky/meta-gumstix-extras/recipes-qt/packagegroups
	@cp /usr/local/share/yocto-overo/packagegroup-qt5.bb \
	  poky/meta-gumstix-extras/recipes-qt/packagegroups/packagegroup-qt5.bb
	@mkdir -p poky/meta-gumstix-extras/recipes-qt/qt5
	@cp /usr/local/share/yocto-overo/qtbase_percent.bbappend \
	  poky/meta-gumstix-extras/recipes-qt/qt5/qtbase_%.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-images/gumstix
	@cp /usr/local/share/yocto-overo/gumstix-console-image.bbappend \
	  poky/meta-gumstix-extras/recipes-images/gumstix/gumstix-console-image.bbappend

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
