.DEFAULT_GOAL := build

YOCTO_VOLUME_NAME := yocto
YOCTO_VOLUME = $(shell docker volume ls --filter name=${YOCTO_VOLUME_NAME} --quiet)

.PHONY: build
build:
	docker build -t gumstix-overo-image --build-arg ARCH=$(uname -m) .

volume:
	@if [ -z "${YOCTO_VOLUME}" ]; then \
		echo "Creating yocto build volume..."; \
		docker volume create ${YOCTO_VOLUME_NAME}; \
	fi

run: volume
	@docker run --rm -it \
		-v ${YOCTO_VOLUME_NAME}:/home/yocto \
		--platform linux/amd64 \
		gumstix-overo-image:latest
