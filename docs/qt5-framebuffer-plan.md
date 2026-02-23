# Add Qt5 Framebuffer Support for Gumstix Overo

## Context

The user wants to build Qt5 applications for the Gumstix Overo Summit board. The Yocto Daisy build runs inside Docker but **does not include meta-qt5** (it's absent from the Gumstix yocto-manifest). The Overo's OMAP3 SoC has a PowerVR SGX GPU supporting OpenGL ES2 via the `libgles-omap3` driver (from meta-ti, which IS in the manifest). The user wants framebuffer rendering (eglfs/linuxfb) with no X11.

## Files to Create (4 new)

### 1. `overo/build/conf/bblayers.conf`
Custom bblayers.conf adding three layers not in the default template:
- **meta-qt5** - Qt5 recipes (Qt 5.2.1 on daisy branch)
- **meta-ti** - TI SGX drivers (`libgles-omap3` providing `virtual/egl`, `virtual/libgles2`)
- **meta-ruby** - Required dependency of meta-qt5
- Uses `${TOPDIR}/../poky/` paths (TOPDIR=/home/yocto/build inside container)

### 2. `overo/poky/meta-gumstix-extras/recipes-qt/packagegroups/packagegroup-qt5.bb`
Packagegroup recipe bundling essential Qt5 modules:
- `qtbase`, `qtbase-plugins` (core + eglfs/linuxfb QPA plugins)
- `qtdeclarative` (QML/Qt Quick)
- `qtsvg`, `qtgraphicaleffects`, `qtimageformats`
- Optional recommends: `qtquickcontrols-qmlplugins`, `qtmultimedia`

### 3. `overo/poky/meta-gumstix-extras/recipes-qt/qt5/qtbase_%.bbappend`
Overo-specific qtbase tweaks:
- Add `tslib` to PACKAGECONFIG (touchscreen support)
- Install `/etc/qt5-env.sh` with default eglfs environment variables

### 4. `overo/poky/meta-gumstix-extras/recipes-images/gumstix/gumstix-console-image.bbappend`
Include Qt5 in the console image:
```
IMAGE_INSTALL_append = " packagegroup-qt5"
```

## Files to Modify (3 existing)

### 5. `Dockerfile`
- **Stage 1 (yocto_repo)**: After `repo sync`, clone meta-qt5 daisy branch into `poky/meta-qt5`
- **Stage 2 (yocto)**: Add COPY directives to stage all new files at `/usr/local/share/yocto-overo/`

### 6. `overo/build/conf/local.conf`
Append Qt5 framebuffer configuration:
- `PREFERRED_PROVIDER_virtual/egl = "libgles-omap3"` (+ libgles1, libgles2)
- `DISTRO_FEATURES_append = " opengl"` and `DISTRO_FEATURES_remove = "x11"`
- `PACKAGECONFIG_GL_pn-qtbase = "gles2"` (OpenGL ES2 + eglfs)
- `PACKAGECONFIG_append_pn-qtbase = " linuxfb"` (software fallback)

### 7. `scripts/Makefile`
Add deploy steps for the new files (bblayers.conf, packagegroup-qt5.bb, qtbase bbappend, image bbappend) following the existing `mkdir -p` + `cp` pattern.

## Verification

1. `make build` on host - Docker image builds successfully, meta-qt5 is cloned
2. `make run` then `make deploy` inside container - all files deployed correctly
3. `make build` inside container - bitbake builds the image with Qt5 packages
4. Resulting image contains qtbase, eglfs/linuxfb plugins, QML runtime
5. On the Overo: `QT_QPA_PLATFORM=eglfs ./myapp` runs a Qt5 app on framebuffer

## Risks

- **SGX driver fetch failures**: TI source servers may be unreliable; pre-cache in `/yocto-mirror/` if needed
- **Kernel/SGX version mismatch**: May need `PREFERRED_VERSION_libgles-omap3` pin if build fails
- **meta-qt5 daisy fetch issues**: Old upstream sources may be dead; `linuxfb` (software rendering) works as fallback without SGX
