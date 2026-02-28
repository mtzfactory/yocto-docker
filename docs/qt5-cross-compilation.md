# Qt5 Cross-Compilation for Gumstix Overo

Guide for setting up a cross-compilation environment to build Qt5 applications
for the Gumstix Overo (OMAP3 / ARM Cortex-A8) board.

## Overview

| Component          | Detail                                      |
|--------------------|---------------------------------------------|
| Target board       | Gumstix Overo (OMAP3530)                    |
| Target ABI         | ARM hard-float (`cortexa8hf-neon`)          |
| Qt version (target)| 5.2.1 (from meta-qt5 / Yocto Daisy)        |
| Display            | Framebuffer (eglfs + OpenGL ES2 via TI SGX) |
| No X11             | Rendering goes directly to `/dev/fb0`       |

## 1. Generate the SDK

Inside the Yocto Docker container:

```bash
make sdk
```

This runs `bitbake -c populate_sdk gumstix-console-image` and produces a
self-extracting installer at:

```
build/tmp/deploy/sdk/oecore-x86_64-cortexa8hf-neon-toolchain-*.sh
```

On the host this maps to `../yocto-data/build/tmp/deploy/sdk/`.

## 2. Install the SDK on Your Development Machine

```bash
# Copy the installer from the Yocto data directory
cp ../yocto-data/build/tmp/deploy/sdk/oecore-*.sh ~/

# Make it executable and run it
chmod +x ~/oecore-*.sh
~/oecore-*.sh
```

The default install path is `/usr/local/oecore-x86_64`.  You can choose a
custom location (e.g. `~/overo-sdk`) when prompted.

The SDK installs:

```
<sdk-root>/
├── environment-setup-arm-oe-linux-gnueabihf   # source this before building
├── sysroots/
│   ├── arm-oe-linux-gnueabihf/                # target sysroot (headers, libs)
│   │   └── usr/
│   │       ├── include/qt5/                    # Qt5 headers
│   │       ├── lib/                            # Qt5 & system libraries
│   │       └── bin/                            # target binaries
│   └── x86_64-oesdk-linux/                     # host tools
│       └── usr/bin/
│           ├── arm-oe-linux-gnueabihf/         # cross-compiler
│           │   ├── arm-oe-linux-gnueabihf-gcc
│           │   ├── arm-oe-linux-gnueabihf-g++
│           │   └── ...
│           └── qt5/                            # host qmake
│               └── qmake
```

## 3. Cross-Compile a Qt Project

### Source the environment

Every terminal session needs this before building:

```bash
source /usr/local/oecore-x86_64/environment-setup-arm-oe-linux-gnueabihf
```

This sets `CC`, `CXX`, `CFLAGS`, `LDFLAGS`, `PKG_CONFIG_PATH`, `QMAKESPEC`,
and other variables pointing at the cross-toolchain and target sysroot.

### Build with qmake

```bash
# Source the SDK environment
source /usr/local/oecore-x86_64/environment-setup-arm-oe-linux-gnueabihf

# Build your project
cd ~/my-qt-app
qmake my-qt-app.pro
make
```

The resulting binary is an ARM hard-float executable ready to run on the Overo.

### Build with CMake

```bash
source /usr/local/oecore-x86_64/environment-setup-arm-oe-linux-gnueabihf

cd ~/my-qt-app
mkdir build && cd build
cmake .. -DCMAKE_FIND_ROOT_PATH=$SDKTARGETSYSROOT
make
```

The environment script sets `$OE_CMAKE_TOOLCHAIN_FILE` if available; otherwise
CMake picks up the cross-compiler from the exported `CC`/`CXX` variables.

## 4. Deploy to the Overo

### Copy the binary

```bash
scp my-qt-app root@<overo-ip>:/home/gumstix/
```

### Run on the Overo

```bash
# Load the Qt5 framebuffer environment
source /etc/qt5-env.sh

# Run the application
./my-qt-app
```

The `qt5-env.sh` script on the target sets:

```bash
export QT_QPA_PLATFORM=eglfs        # use EGL framebuffer surface
export QT_QPA_EGLFS_INTEGRATION=none
export QT_QPA_EGLFS_DEPTH=16        # 16-bit color for OMAP3
```

### Alternative: software rendering fallback

If the SGX drivers aren't working, use the Linux framebuffer backend:

```bash
./my-qt-app -platform linuxfb
```

## 5. Configure Qt Creator for Cross-Compilation

### Install Qt Creator on your host

```bash
sudo apt install qtcreator qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools
```

### Add the Overo cross-compilation kit

1. **Tools > Options > Devices > Add > Generic Linux Device**
   - Hostname: Overo's IP address
   - Username: `root`

2. **Tools > Options > Compilers > Add > GCC > C++**
   - Path: `<sdk-root>/sysroots/x86_64-oesdk-linux/usr/bin/arm-oe-linux-gnueabihf/arm-oe-linux-gnueabihf-g++`
   - ABI: `arm-linux-generic-elf-32bit`

3. **Tools > Options > Qt Versions > Add**
   - Path: `<sdk-root>/sysroots/x86_64-oesdk-linux/usr/bin/qt5/qmake`

4. **Tools > Options > Kits > Add**
   - Name: `Overo (ARM hardfp)`
   - Device: the Generic Linux Device from step 1
   - Compiler: the cross-compiler from step 2
   - Qt version: the qmake from step 3
   - Sysroot: `<sdk-root>/sysroots/arm-oe-linux-gnueabihf`

Now you can select the "Overo" kit in any project to cross-compile and deploy
directly from Qt Creator.

## 6. Available Qt5 Modules

The SDK includes development files for these modules:

| Module               | Description                        |
|----------------------|------------------------------------|
| qtbase               | Core, GUI, Widgets, Network, SQL   |
| qtbase-plugins       | eglfs, linuxfb platform plugins    |
| qtdeclarative        | QML / Qt Quick 2                   |
| qtgraphicaleffects   | Shader-based visual effects        |
| qtimageformats       | TIFF, MNG, TGA, WBMP support      |
| qtsvg                | SVG rendering                      |
| qtmultimedia         | Audio/video playback (optional)    |
| qtquickcontrols      | QML UI controls (optional)         |

## 7. Example: Minimal Qt5 Application

### main.cpp

```cpp
#include <QApplication>
#include <QLabel>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QLabel label("Hello from Overo!");
    label.setAlignment(Qt::AlignCenter);
    label.resize(320, 240);
    label.show();
    return app.exec();
}
```

### hello-overo.pro

```
QT       += core gui widgets
TARGET    = hello-overo
SOURCES  += main.cpp
```

### Build and deploy

```bash
source /usr/local/oecore-x86_64/environment-setup-arm-oe-linux-gnueabihf
qmake hello-overo.pro
make
scp hello-overo root@<overo-ip>:/home/gumstix/
```

### Run on the Overo

```bash
source /etc/qt5-env.sh
./hello-overo
```

## 8. Troubleshooting

**"Could not find or load the Qt platform plugin eglfs"**
- Ensure the SGX kernel module is loaded: `lsmod | grep pvrsrvkm`
- Run the PVR init script: `/etc/init.d/pvr-init start`
- Fall back to software rendering: `./app -platform linuxfb`

**"EGLFS: Failed to open /dev/fb0"**
- Check framebuffer exists: `ls /dev/fb*`
- Check permissions: run as root or add user to `video` group

**Linker errors about missing libraries**
- Make sure you sourced the environment: `source environment-setup-arm-oe-linux-gnueabihf`
- Check `$PKG_CONFIG_PATH` points into the SDK sysroot

**"file not recognized: file format not recognized"**
- You're mixing host and target binaries; run `make clean` and rebuild
  after sourcing the SDK environment
