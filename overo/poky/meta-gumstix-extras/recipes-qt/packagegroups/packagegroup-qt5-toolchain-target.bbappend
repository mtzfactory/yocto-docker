# The upstream packagegroup pulls in qtwebkit, qtquick1, and qttools-plugins
# via USE_RUBY (ruby-layer is in bblayers.conf) but those packages don't
# build without X11/WebKit deps.  Override RDEPENDS with modules we have.

RDEPENDS_${PN} = " \
    packagegroup-core-standalone-sdk-target \
    libsqlite3-dev \
    qtbase-dev \
    qtbase-fonts \
    qtbase-mkspecs \
    qtbase-plugins \
    qtbase-staticdev \
    qtdeclarative-dev \
    qtdeclarative-mkspecs \
    qtdeclarative-plugins \
    qtdeclarative-qmlplugins \
    qtdeclarative-staticdev \
    qtgraphicaleffects-qmlplugins \
    qtimageformats-dev \
    qtimageformats-plugins \
    qtmultimedia-dev \
    qtmultimedia-mkspecs \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qtsvg-dev \
    qtsvg-mkspecs \
    qtsvg-plugins \
    qttools-dev \
    qttools-mkspecs \
    qttools-staticdev \
    qttools-tools \
    qtxmlpatterns-dev \
    qtxmlpatterns-mkspecs \
"

RRECOMMENDS_${PN} = " \
    qtquickcontrols-qmlplugins \
"
