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
	@mkdir -p poky/meta-gumstix-extras/recipes-graphics/libgles
	@cp /usr/local/share/yocto-overo/libgles-omap3_percent.bbappend \
	  poky/meta-gumstix-extras/recipes-graphics/libgles/libgles-omap3_%.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-qt/packagegroups
	@cp /usr/local/share/yocto-overo/packagegroup-qt5.bb \
	  poky/meta-gumstix-extras/recipes-qt/packagegroups/packagegroup-qt5.bb
	@cp /usr/local/share/yocto-overo/packagegroup-qt5-toolchain-target.bbappend \
	  poky/meta-gumstix-extras/recipes-qt/packagegroups/packagegroup-qt5-toolchain-target.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-qt/qt5
	@cp /usr/local/share/yocto-overo/qtbase_percent.bbappend \
	  poky/meta-gumstix-extras/recipes-qt/qt5/qtbase_%.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-bsp/powervr-drivers
	@cp /usr/local/share/yocto-overo/omap3-sgx-modules_4.05.00.03.bbappend \
	  poky/meta-gumstix-extras/recipes-bsp/powervr-drivers/omap3-sgx-modules_4.05.00.03.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-images/gumstix
	@cp /usr/local/share/yocto-overo/gumstix-console-image.bbappend \
	  poky/meta-gumstix-extras/recipes-images/gumstix/gumstix-console-image.bbappend
	@mkdir -p poky/meta-gumstix-extras/recipes-kernel/linux/files
	@cp /usr/local/share/yocto-overo/linux-gumstix_3.5.7.bbappend \
	  poky/meta-gumstix-extras/recipes-kernel/linux/linux-gumstix_3.5.7.bbappend
	@cp /usr/local/share/yocto-overo/0036-Add-missing-SGX-header.patch \
	  poky/meta-gumstix-extras/recipes-kernel/linux/files/0036-Add-missing-SGX-header.patch

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
