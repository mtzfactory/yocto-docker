FROM ubuntu:14.04.5

# Install necessary packages
RUN apt-get update && \
  apt-get -y install software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update && apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
  build-essential chrpath socat libsdl1.2-dev xterm python python3.7 tar locales cpio git libncurses5-dev \
  pkg-config subversion texi2html texinfo curl sudo libncursesw5-dev vim

#gcc-8 g++-8

# Set host GCC to GCC8 - fix for openjdk-8 compilation
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8

# use python3 for repo
RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3.7 /usr/bin/python
RUN python --version

# Set default shell to BASH for source
RUN rm /bin/sh && ln -s bash /bin/sh

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Set yocto root directory (directory with build/ and poky/) -> even though user hasnt been created yet, this is needed to clone yocto-manifest into.
ENV YOCTO_DIR /yocto

# Download and intall repo
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
RUN chmod a+x repo
RUN mv repo /usr/local/bin

# misc utils
COPY runbb /usr/local/bin
RUN chmod a+x /usr/local/bin/runbb

COPY create_user /usr/local/bin
RUN chmod a+x /usr/local/bin/create_user

COPY backup_images /usr/local/bin
RUN chmod a+x /usr/local/bin/backup_images

# Create yocto directory
RUN mkdir -p ${YOCTO_DIR}/
WORKDIR ${YOCTO_DIR}

# Pull poky layers, initiate conf/
RUN repo init -u git://github.com/gumstix/yocto-manifest.git -b refs/tags/daisy
RUN repo sync
ENV PARALLEL_MAKE="-j 8"
ENV TEMPLATECONF=meta-gumstix-extras/conf
RUN source poky/oe-init-build-env build

# Switch back to python2 for bitbake
RUN rm /usr/bin/python
RUN ln -s /usr/bin/python2 /usr/bin/python

# MACHINE as defined in local.conf
ENV MACHINE=overo
ENV IMAGE=gumstix-console-image

# Default UID and GID values - set in docker run using '-e' flag (i.e. docker run -e UID=$(id -u) yocto-build-env:latest)
ENV UID=1001
ENV GID=1001

ENV USERNAME=yocto
ENV GROUP=yocto

ENV NEW_IMG=false
ENV JDK_FETCH=false

# build command
CMD \
  # New user creation and permission changes
  create_user; \
  # Run rest of commands as new user
  runuser ${USERNAME} -p -c " \
  if [[ ${NEW_IMG} == true ]]; then \
  echo 'backing up images folder'; \
  backup_images; \
  fi; \
  echo 'setting up local.conf' \
  && sed -i 's/^COMPATIBLE_MACHINE_overo = \"overo\"/#COMPATIBLE_MACHINE_overo = \"overo\"/g' ${YOCTO_DIR}/build/conf/local.conf \
  && sed -i 's/^MACHINE ?= \"overo\"/#MACHINE ?= \"overo\"\nMACHINE ?= \"'\"${MACHINE}\"'\"/g' ${YOCTO_DIR}/build/conf/local.conf; \
  # Run bitbake
  if [[ ${JDK_FETCH} == true ]]; then \
  runbb -j -i ${IMAGE}; \
  else \
  runbb -i ${IMAGE}; \
  fi; \
  "
