# Ship GPU demo binaries and desktop files installed by the TI SDK
# that the upstream meta-ti recipe does not assign to any package.
FILES_${PN} += "/usr/share /usr/share/applications /usr/lib/ES2.0"

# The TI SDK's ES*.0 sub-directories contain pre-compiled binaries — some
# built for soft-float (ld-linux.so.3) and some with X11 DRI deps
# (libXext.so.6).  Neither is satisfiable in our hardfp/no-x11 build.
#
# Fix: (1) remove X11 DRI binaries from ES dirs, (2) don't recommend ES
# sub-packages so the package manager won't try to install them.  The base
# package already ships the correct hardfp libraries; the ES sub-packages
# are silicon-revision variants selected at runtime by the init script.
do_install_append() {
    find ${D}${libdir}/ES*.0 -name "pvr_drv.so*" -delete 2>/dev/null || true
    find ${D}${libdir}/ES*.0 -name "libsrv_um_dri.so*" -delete 2>/dev/null || true
    find ${D}${libdir}/ES*.0 -name "libpvrPVR2D_DRIWSEGL.so*" -delete 2>/dev/null || true
}

# Don't pull ES sub-packages into the image — they contain softfp binaries
# that require ld-linux.so.3 (unavailable in hardfp builds).
RRECOMMENDS_${PN} = "omap3-sgx-modules"
