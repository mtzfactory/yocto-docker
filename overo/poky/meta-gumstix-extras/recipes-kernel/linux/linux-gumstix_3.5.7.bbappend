# Add missing SGX platform_data header required by omap3-sgx-modules 5.01.01.02
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://0036-Add-missing-SGX-header.patch"
