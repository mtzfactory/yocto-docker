FROM ubuntu:20.04 AS yocto_repo

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt update \
 && apt install -y \
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
    xterm

# Set locale - required for bitbake
RUN locale-gen en_US.UTF-8 \
 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN add-apt-repository ppa:deadsnakes/ppa \
 && apt install -y \
    python3 \
    python2 \
 && apt autoremove \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2

ADD http://commondatastorage.googleapis.com/git-repo-downloads/repo repo
RUN chmod a+x repo \
 && mv repo /usr/local/bin

ENV YOCTO_DIR $HOME/gumstix/yocto

RUN mkdir -p ${YOCTO_DIR}/
WORKDIR ${YOCTO_DIR}

RUN git config --global user.email "ricardo.martinez.monje@gmail.com" && \
    git config --global user.name "mtzfactory" && \
    git config --global url."https://".insteadOf git://

RUN repo init -u git://github.com/gumstix/yocto-manifest.git -b refs/tags/daisy && \
    repo sync

WORKDIR /

CMD ["/bin/bash"]

##
###
##

FROM ubuntu:14.04.5 AS yocto

RUN apt update \
 && apt install -y \
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
RUN locale-gen en_US.UTF-8 \
 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN add-apt-repository ppa:deadsnakes/ppa \
 && apt install -y \
    python \
 && rm -rf /var/lib/apt/lists/*

# Misc utils
COPY scripts/backup_images /usr/local/bin
RUN chmod a+x /usr/local/bin/backup_images

COPY scripts/create_user /usr/local/bin
RUN chmod a+x /usr/local/bin/create_user

COPY scripts/runbb /usr/local/bin
RUN chmod a+x /usr/local/bin/runbb

ENV YOCTO_DIR $HOME/gumstix/yocto

# Create bitbake user
ENV UID=1001
ENV GID=1001

ENV USERNAME=yocto
ENV GROUP=yocto

RUN create_user \
 && su yocto


# Create yocto directory
RUN mkdir -p ${YOCTO_DIR}/
WORKDIR ${YOCTO_DIR}

# Copy from previous build
COPY --from=yocto_repo /root/gumstix/yocto/ .

# Init build environment
ENV TEMPLATECONF=meta-gumstix-extras/conf
RUN source poky/oe-init-build-env

# Copy overo customization
COPY overo/build/conf/local.conf ${YOCTO_DIR}/local.conf
COPY overo/poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb \
     ${YOCTO_DIR}/poky/meta-gumstix-extras/recipes-graphics/raw2rgbpnm/raw2rgbpnm_git.bb

CMD ["/bin/bash"]

##
###
##

FROM yocto AS gumstix_overo

RUN su yocto

ENV YOCTO_DIR $HOME/gumstix/yocto
WORKDIR ${YOCTO_DIR}

COPY scripts/Makefile ${YOCTO_DIR}/Makefile
COPY scripts/yocto.env ${YOCTO_DIR}/yocto.env

CMD ["/bin/bash"]
