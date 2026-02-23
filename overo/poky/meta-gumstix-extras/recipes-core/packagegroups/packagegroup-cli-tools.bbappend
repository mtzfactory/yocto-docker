# Remove packages with dead upstream sources from packagegroup-cli-tools.
# nmon: SourceForge source returns 404
# dbus-daemon-proxy: git.collabora.co.uk no longer resolves
RDEPENDS_${PN} = "\
    dosfstools \
    htop \
    iptables \
    lsof \
    mbuffer \
    mtd-utils \
    nano \
    nfs-utils-client \
    powertop \
    screen \
    socat \
    sysstat \
"

# pxaregs: upstream at mn-logistik.de is dead (PXA tool, irrelevant for OMAP3/Overo)
RDEPENDS_${PN}-debug = "\
    evtest \
    devmem2 \
    i2c-tools \
    gdb \
    procps \
    s3c24xx-gpio \
    s3c64xx-gpio \
    serial-forward \
    strace \
"
