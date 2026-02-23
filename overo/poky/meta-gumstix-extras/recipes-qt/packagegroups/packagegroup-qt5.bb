SUMMARY = "Qt5 framebuffer packages for Gumstix Overo"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = "\
    qtbase \
    qtbase-plugins \
    qtdeclarative \
    qtgraphicaleffects \
    qtimageformats \
    qtsvg \
    qtsvg-plugins \
"

RRECOMMENDS_${PN} = "\
    qtquickcontrols-qmlplugins \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
"
