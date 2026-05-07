DESCRIPTION = "Systemd service unit for the system-dashboard Qt5 application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://system-dashboard.service"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE_${PN} = "system-dashboard.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install() {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/system-dashboard.service \
        ${D}${systemd_unitdir}/system/system-dashboard.service
}

FILES_${PN} = "${systemd_unitdir}/system/system-dashboard.service"
