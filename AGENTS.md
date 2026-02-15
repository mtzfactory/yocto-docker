# Repository Guidelines

## Project Structure & Module Organization
- `Dockerfile`: multi-stage image that sets up the Yocto/Bitbake environment (`yocto_repo`, `yocto`, `gumstix_overo`).
- `Makefile`: host-side targets to build the image and run a container.
- `scripts/`: helper scripts and guest Makefile copied into the container (user setup, backups, build targets).
- `overo/`: Overo-specific Yocto configuration and custom recipes (`build/conf/local.conf`, `poky/meta-gumstix-extras/`).
- `README.md`: end-to-end usage examples for running builds via Docker.

## Build, Test, and Development Commands
- `make build`: builds the local Docker image (`gumstix-overo-image`) from `Dockerfile`.
- `make build DOCKER_BUILD_NETWORK=host`: builds using host networking when bridge networking cannot reach upstream git remotes.
- `make run`: creates the Docker volume (if missing) and runs the build container.
- `make run YOCTO_HOST_DIR=$PWD/yocto-data`: bind-mounts a host folder to `/home/yocto` instead of using the named volume.
  Default host dir is `../yocto-data`. For bind mounts, ensure host folder ownership matches container UID:GID (default `1000:1000`).
- `make volume`: creates the named Docker volume used for Yocto state.
- `docker run ... gumstix/yocto-builder:latest`: builds using the published image (see `README.md`).
- `make build UID=$(id -u) GID=$(id -g)`: builds with custom UID/GID to match host user (default 1000:1000).
- Inside container: `make build` (default image), `make build IMAGE=<name>` (custom image).
- Inside container: `make fetch-all`, `make fetch-jdk`, `make sdk` for other build tasks.
- The guest `Makefile` `deploy` target copies staged overo configs before each build.
- The `entrypoint` script deploys the guest `Makefile` into the working directory at container startup, so it survives volume/bind mounts.

## Coding Style & Naming Conventions
- Indentation: 2 spaces for shell scripts/Makefiles when adding new blocks (match existing style).
- Use POSIX shell where possible; keep scripts small and focused.
- Filenames: lowercase with underscores in `scripts/` (e.g., `create_user`).
- Dockerfile edits should keep stages labeled and ordered; prefer explicit `ARG`/`ENV` names.
- Prefer fewer Docker layers: combine related `RUN`/`COPY` steps, use `--no-install-recommends`, and clean apt lists in the same layer.
- Do not change Yocto branch/tag, Ubuntu base versions, or manifest URLs unless explicitly requested; this repo targets a legacy toolchain.

## Testing Guidelines
- No automated test suite in this repo.
- Validate changes by building the image (`make build`) and running a sample Yocto build
  in the container (see `README.md` for `docker run` examples).
- For Dockerfile-only changes, at minimum verify image build success and container startup (`make run` or equivalent `docker run`).
- For script changes, run the modified script path in-container and confirm expected behavior with non-root `yocto` user.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and capitalized (e.g., “Change volume name in Makefile variable”).
- PRs should describe the goal, list major changes, and include build commands run.
- Link any related issues and note environment assumptions (host OS, Docker version).
- Call out compatibility impact explicitly when changing Docker base image, package sources, or Yocto manifest revision.

## Configuration & Security Notes
- Do not commit generated Yocto output or downloads.
- Build args `UID` and `GID` control the container user identity (default 1000:1000). Overo configs and the guest Makefile are staged to `/usr/local/share/yocto*/` so they persist across mounts.
- Environment variables used by builds: `YOCTO_DIR`, `TEMPLATECONF`, `MACHINE`, `IMAGE`.
- Use HTTPS for fetched artifacts when possible and avoid unauthenticated remote `ADD`.
