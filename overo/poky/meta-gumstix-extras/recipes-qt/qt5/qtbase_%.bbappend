PACKAGECONFIG_append = " tslib"

do_install_append() {
    install -d ${D}${sysconfdir}
    cat > ${D}${sysconfdir}/qt5-env.sh <<'QTEOF'
#!/bin/sh
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=none
export QT_QPA_EGLFS_DEPTH=16
QTEOF
    chmod 0644 ${D}${sysconfdir}/qt5-env.sh
}

FILES_${PN} += "${sysconfdir}/qt5-env.sh"
