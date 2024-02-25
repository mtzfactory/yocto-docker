# Use the official Ubuntu 14.04.5 image as the base image
FROM ubuntu:22.04 as builder

RUN apt update && \
  apt install -y \
  build-essential \
  chrpath \
  curl \
  diffstat \
  gawk \
  gcc-multilib-x86-64-linux-gnu \
  git-core \
  libsdl1.2-dev \
  locales \
  software-properties-common \
  texinfo \
  unzip \
  wget \
  xterm

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt update && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt install -y \
  python3 \
  python2

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3 2

RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo && \
  chmod a+x repo && \
  mv repo /usr/local/bin

# Set yocto root directory (directory with build/ and poky/) -> even though user hasnt been created yet, this is needed to clone yocto-manifest into.
ENV YOCTO_DIR $HOME/gumstix/yocto

# Create yocto directory
RUN mkdir -p ${YOCTO_DIR}/
WORKDIR ${YOCTO_DIR}

RUN git config --global user.email "ricardo.martinez.monje@gmail.com" && \
  git config --global user.name "mtzfactory" && \
  git config --global url."https://".insteadOf git://

# Pull poky layers, initiate conf/
RUN repo init -u git://github.com/gumstix/yocto-manifest.git -b refs/tags/daisy && \
  repo sync

WORKDIR /

CMD ["/bin/bash"]

##
###
##

FROM ubuntu:14.04.5

RUN apt update && \
  apt install -y \
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
  wget \
  vim \
  xterm

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt update && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt install -y \
  python

# misc utils
COPY runbb /usr/local/bin
RUN chmod a+x /usr/local/bin/runbb

COPY create_user /usr/local/bin
RUN chmod a+x /usr/local/bin/create_user

COPY backup_images /usr/local/bin
RUN chmod a+x /usr/local/bin/backup_images

# Default UID and GID values - set in docker run using '-e' flag (i.e. docker run -e UID=$(id -u) yocto-build-env:latest)
ENV UID=1001
ENV GID=1001

ENV USERNAME=yocto
ENV GROUP=yocto

# Set yocto root directory (directory with build/ and poky/) -> even though user hasnt been created yet, this is needed to clone yocto-manifest into.
ENV YOCTO_DIR /gumstix/yocto

# Create yocto directory
RUN mkdir -p ${YOCTO_DIR}/
WORKDIR ${YOCTO_DIR}

COPY --from=builder $HOME/gumstix/yocto/ .

ENV PARALLEL_MAKE="-j 8"
ENV TEMPLATECONF=meta-gumstix-extras/conf

RUN create_user ${YOCTO_DIR}

# RUN su yocto && \
#   source poky/oe-init-build-env && \
#   bitbake -c fetchall gumstix-console-image

CMD ["/bin/bash"]
