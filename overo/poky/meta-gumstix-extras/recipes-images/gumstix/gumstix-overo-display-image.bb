DESCRIPTION = "Gumstix Overo Summit display image with Qt5 linuxfb runtime"
LICENSE = "MIT"

require gumstix-console-image.bb

IMAGE_INSTALL += " \
    qtbase \
    qtbase-plugins \
    qtdeclarative \
    qtdeclarative-qmlplugins \
    system-dashboard-service \
"
