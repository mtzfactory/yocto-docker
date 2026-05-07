# nmon: SourceForge download URL is dead (blacklisted in local.conf)
# dbus-daemon-proxy: upstream at git.collabora.co.uk no longer resolves
# (blacklisted in local.conf); not needed — systemd manages the D-Bus system bus
# pxaregs: PXA register dump tool, irrelevant for Overo (OMAP3); source gone
RDEPENDS_${PN}_remove       = "nmon dbus-daemon-proxy pxaregs"
RDEPENDS_${PN}-debug_remove = "nmon dbus-daemon-proxy pxaregs"
