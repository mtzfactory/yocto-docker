.DEFAULT_GOAL := build

YOCTO_VOLUME_NAME := yocto
YOCTO_VOLUME = $(shell docker volume ls --filter name=${YOCTO_VOLUME_NAME} --quiet)
YOCTO_HOST_DIR ?= $(realpath ../yocto-data)
YOCTO_MIRROR_DIR ?= $(realpath ../yocto-mirror)
IMAGE_NAME := gumstix-overo-image
DOCKER_BUILD_NETWORK ?= default
UID ?= 1000
GID ?= 1000

.PHONY: build
build:
	docker build --network ${DOCKER_BUILD_NETWORK} -t ${IMAGE_NAME} --build-arg ARCH=$(shell uname -m) --build-arg UID=${UID} --build-arg GID=${GID} .

volume:
	@if [ -z "${YOCTO_HOST_DIR}" ] && [ -z "${YOCTO_VOLUME}" ]; then \
		echo "Creating yocto build volume..."; \
		docker volume create ${YOCTO_VOLUME_NAME}; \
	fi

run: build volume
	@if [ -n "${YOCTO_HOST_DIR}" ]; then \
		mkdir -p "${YOCTO_HOST_DIR}"; \
		MOUNT_ARG="-v ${YOCTO_HOST_DIR}:/home/yocto"; \
	else \
		MOUNT_ARG="-v ${YOCTO_VOLUME_NAME}:/home/yocto"; \
	fi; \
	docker run --rm -it \
		$$MOUNT_ARG \
		-v ${YOCTO_MIRROR_DIR}:/yocto-mirror \
		--platform linux/amd64 \
		${IMAGE_NAME}:latest
