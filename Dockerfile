ARG YOCTO_REPO=/root/yocto
ARG YOCTO_DIR=/home/yocto
ARG USERNAME=yocto

##
###
##

FROM ubuntu:20.04 AS yocto_repo

ARG YOCTO_REPO

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install packages
RUN apt-get update && \
  apt-get install -y \
  git-core \
  software-properties-common

# Add python
RUN add-apt-repository ppa:deadsnakes/ppa && \
  apt-get install -y \
  python3 && \
  apt-get autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Download repo tool
ADD http://commondatastorage.googleapis.com/git-repo-downloads/repo repo
RUN chmod a+x repo && \
  mv repo /usr/local/bin

# Create yocto directory
RUN mkdir -p ${YOCTO_REPO}/
WORKDIR ${YOCTO_REPO}

# Configure git
RUN git config --global user.email "ricardo.martinez.monje@gmail.com" && \
  git config --global user.name "mtzfactory" && \
  git config --global url."https://".insteadOf git://

# Clone yocto manifest
RUN repo init -u git://github.com/gumstix/yocto-manifest.git -b refs/tags/daisy && \
  repo sync

CMD ["/bin/bash"]

##
###
##

FROM ubuntu:14.04.5 AS yocto

ARG YOCTO_REPO
ARG YOCTO_DIR
ARG USERNAME

SHELL ["/bin/bash", "-c"]

# Install packages
RUN apt-get update && \
  apt-get install -y \
  build-essential \
  chrpath \
  curl \
  diffstat \
  gawk \
  gcc-multilib \
  git-core \
  libsdl1.2-dev \
  locales \
  software-properties-common \
  texinfo \
  unzip \
  vim \
  wget \
  xterm

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add python
RUN add-apt-repository ppa:deadsnakes/ppa && \
  apt-get install -y \
  python && \
  rm -rf /var/lib/apt/lists/*

# Misc utils
COPY scripts/backup_images /usr/local/bin
RUN chmod a+x /usr/local/bin/backup_images

COPY scripts/create_user /usr/local/bin
RUN chmod a+x /usr/local/bin/create_user

COPY scripts/runbb /usr/local/bin
RUN chmod a+x /usr/local/bin/runbb

# Create bitbake user
ENV UID 1001
ENV GID 1001
ENV GROUP yocto

RUN create_user

# Use yocto directory
WORKDIR ${YOCTO_DIR}

# Copy repo from previous build
COPY --from=yocto_repo ${YOCTO_REPO} .
RUN chown -R ${USERNAME}:${GROUP} .

# Switch to user
USER ${USERNAME}

# Init build environment
ENV TEMPLATECONF=meta-gumstix-extras/conf
RUN source poky/oe-init-build-env

# Copy overo customization
COPY overo/build/conf/local.conf ${YOCTO_DIR}/build/conf/local.conf
COPY overo/poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb \
  ${YOCTO_DIR}/poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb

# Copy Makefile
COPY scripts/Makefile ${YOCTO_DIR}/Makefile

CMD ["/bin/bash"]

##
###
##

FROM yocto AS gumstix_overo

ARG YOCTO_DIR
ARG USERNAME

USER ${USERNAME}

WORKDIR ${YOCTO_DIR}

# Init build environment
ENV TEMPLATECONF=meta-gumstix-extras/conf

CMD ["/bin/bash"]
