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
$ git clone git@github.com:gumstix/yocto-docker.git

```
After cloning repository, build image with
```sh
$ docker build --no-cache --tag "gumstix/yocto-builder:latest" Yocto-Docker
```

For this repository Makefile:
```sh
$ make build
```

If Docker build networking cannot reach git remotes, use host networking:
```sh
$ make build DOCKER_BUILD_NETWORK=host
```

Run container with default named volume:
```sh
$ make run
```

Run container with a host directory instead of Docker volume:
```sh
$ make run YOCTO_HOST_DIR=$PWD/yocto-data
```

To customize the container user UID/GID (defaults to 1000:1000):
```sh
$ make build UID=$(id -u) GID=$(id -g)
```

If using `YOCTO_HOST_DIR` and you see `Permission denied` under `/home/yocto/build`,
fix host directory ownership to match the container `yocto` user (default `UID:GID 1000:1000`):
```sh
$ sudo chown -R 1000:1000 $PWD/yocto-data
```

### Workflow

1. **Build the Docker image** (host):
```sh
$ make build
```

2. **Start the container** (host):
```sh
$ make run
```

3. **Build inside the container**:
```sh
$ make build                    # build default image (gumstix-console-image)
$ make build IMAGE=my-image     # build a custom image
$ make fetch-all                # fetch all sources without building
$ make fetch-jdk                # fetch openjdk-8
$ make sdk                      # build the SDK
```

The guest `Makefile` automatically deploys overo configuration templates (`local.conf`, custom recipes) from staged copies before each build. This ensures the correct settings are always applied, even when using a bind-mounted host directory.

For more detailed build information, see [gumstix/yocto-manifest](https://github.com/gumstix/yocto-manifest/#:~:text=Initialize%20the%20Yocto%20Project%20Build%20Environment)

***
