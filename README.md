<!--

NOTE: "gumstix/yocto-builder" is a placeholder for Image repo on Dockerhub once it becomes
hosted.

-->

# Yocto-Docker
This is a Docker image to build gumstix Yocto images in a controlled Linux environment. This image is based on Ubuntu 18.04, using the repo manifest found at https://github.com/gumstix/yocto-manifest/tree/dunfell. Current image builds the Dunfell branch of Gumstix images.

### Manually building Docker image from Dockerfile
***
**Note:** Building the docker image is optional. Docker will fetch a prebuilt image from dockerhub if an image is not found locally.
***
Clone repository with 
```
$ git clone git@github.com:Yoruio/Gumstix-Yocto-Docker.git
```
After cloning repository, build image with
```sh
$ docker build --no-cache --tag "gumstix/yocto-builder:latest" Yocto-Docker
```

### Building Yocto image without modification
#### Start container and build Yocto with default settings:
<!--*If you made changes to Yocto, skip this.*-->
```sh
$ docker run --rm -it \
  -v [host output directory]/output:/yocto/build/tmp/deploy/images \
  -v [host downloads directory]:/yocto/build/downloads \
  -e MACHINE=[machine name] \
  -e IMAGE=[image name] \
  -e UID=$(id -u) -e GID=$(id -g) \
  gumstix/yocto-builder:latest
```
**[host output directory]:** The directory on the host machine where images will be sent to after the build is completed.

**[host downloads directory]:** A directory on the host machine where downloaded sources will be saved. This is optional if you don't want to reuse sources between builds.

**[machine name]:** Machine that the image will be installed on, e.g. *raspberrypi4-64* or *overo* (default raspberrypi4-64)

**[image name]:** Image(s) that yocto will build, separated by spaces. e.g. *gumstix-console-image packagegroup-gumstix*  (default gumstix-console-image)

for example, building gumstix-lxqt-image for raspberrypi4-64, outputting to the ~/gumstix-image/ directory, and without persistent downloads:
```sh
$ docker run --rm -it \
  -v ~/gumstix-image:/yocto/build/tmp/deploy/images \
  -e MACHINE=raspberrypi4-64 \
  -e IMAGE=gumstix-lxqt-image \
  -e UID=$(id -u) -e GID=$(id -g) \
  gumstix/yocto-builder:latest
```

### Making changes to Yocto
Start and enter Docker container to make changes:
```sh
$ docker run -it --entrypoint=/bin/bash \
  -v [host output directory]/output:/yocto/build/tmp/deploy/images \
  -v [host downloads directory]:/yocto/build/downloads \
  -e UID=$(id -u) -e GID=$(id -g) \
  gumstix/yocto-builder:latest \
  --name "gumstix_docker_image"
```
Prepare images directory and switch to correct user for yocto build:
```sh
$ create_user && backup_images
$ su - -m yocto
```
At this point, make any changes to yocto as necessary (new recipes, different sources, etc). Remember to also make necessary changes in `/yocto/build/conf/local.conf`, particularly the `MACHINE` variable if you are not building for the Overo.

Source Poky and run Bitbake with:
```sh
$ cd /yocto
$ source poky/oe-init-build-env
$ bitbake [images]
```
***
At any point in the process, you can exit the container by typing `exit`, and re-attach to it later on:
```sh
$ docker start gumstix_docker_image
$ docker attach gumstix_docker_image
```

For more detailed build information, see [gumstix/yocto-manifest](https://github.com/gumstix/yocto-manifest/#:~:text=Initialize%20the%20Yocto%20Project%20Build%20Environment)

***