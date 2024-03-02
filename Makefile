.DEFAULT_GOAL := build

.PHONY: build
build:
	docker build -t gumstix-overo-image --build-arg ARCH=$(uname -m) .

volume:
	  docker volume create yocto_build

run:
	YOCTO_VOLUME=$(docker volume ls --filter name=yocto_build --quiet)
	if [ -z "${YOCTO_VOLUME}" ]; then echo "YOCTO_VOLUME must be set"; false; fi

	docker run --rm -it \
		-v "${YOCTO_VOLUME}":/gumstix/yocto/build \
		gumstix-overo-image:latest
