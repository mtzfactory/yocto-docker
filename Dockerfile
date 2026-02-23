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
  software-properties-common;

# Add python
RUN add-apt-repository "ppa:deadsnakes/ppa" && \
  apt-get install -y python3 && \
  apt-get autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*;

# Download repo tool
ADD http://commondatastorage.googleapis.com/git-repo-downloads/repo repo
RUN chmod a+x repo && \
  mv repo /usr/local/bin;

# Create yocto directory
RUN mkdir -p "${YOCTO_REPO}/"
WORKDIR ${YOCTO_REPO}

# Configure git
RUN git config --global user.email "200234+mtzfactory@users.noreply.github.com" && \
  git config --global user.name "mtzfactory" && \
  git config --global url."https://".insteadOf "git://"

# Clone yocto manifest
RUN repo init -u "git://github.com/gumstix/yocto-manifest.git" -b refs/tags/daisy && \
  repo sync;

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
  xterm;

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8;
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add python
RUN add-apt-repository ppa:deadsnakes/ppa && \
  apt-get install -y \
  python && \
  rm -rf /var/lib/apt/lists/*;

# Misc utils
COPY scripts/backup_images /usr/local/bin
RUN chmod a+x /usr/local/bin/backup_images;

COPY scripts/create_user /usr/local/bin
RUN chmod a+x /usr/local/bin/create_user;

COPY scripts/entrypoint /usr/local/bin
RUN chmod a+x /usr/local/bin/entrypoint;

# wget uses GnuTLS 2.12 which has a TLS 1.2 bug (LP#1444656);
# use curl (OpenSSL) wrapper as a drop-in replacement for BitBake fetches
COPY scripts/wget-curl-wrapper /usr/local/bin
RUN chmod a+x /usr/local/bin/wget-curl-wrapper;

# Create bitbake user
ARG UID=1000
ARG GID=1000
ENV UID=${UID}
ENV GID=${GID}
ENV GROUP=yocto

RUN create_user;

# Use yocto directory
WORKDIR ${YOCTO_DIR}

# Copy repo from previous build
COPY --from=yocto_repo ${YOCTO_REPO} .
RUN chown -R ${USERNAME}:${GROUP} .;

# Switch to user
USER ${USERNAME}

# Init build environment
ENV TEMPLATECONF=meta-gumstix-extras/conf
RUN source poky/oe-init-build-env;

# Copy overo customization templates (deployed by guest Makefile before builds)
COPY overo/build/conf/local.conf /usr/local/share/yocto-overo/local.conf
COPY overo/poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb \
  /usr/local/share/yocto-overo/raw2rgbpnm_git.bb

# Stage Makefile for entrypoint deployment
COPY scripts/Makefile /usr/local/share/yocto/Makefile

ENTRYPOINT ["entrypoint"]
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
