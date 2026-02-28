# Fix omap3-sgx-modules compilation against kernel 3.5+.
#
# 1. bc_cat.c uses cpu_is_omap3530() / omap_rev() / OMAP3430_REV_ES3_0 but
#    does not include <plat/cpu.h> (unlike sgxinit.c, which gets them via its
#    own include chain).  Stub them as macros only in bc_cat.c.
#
# 2. omaplfb_linux.c: enum omap_dss_update_mode and the get/set_update_mode
#    DSS driver callbacks were removed in kernel 3.5.  Re-add the enum as a
#    compat shim (guarded by #ifndef so it is idempotent) and stub out the
#    struct member accesses so the functions take their early-return paths.

do_compile_prepend() {
    # --- bc_cat.c: stub removed OMAP CPU-detection macros ---
    # Only bc_cat.c needs these stubs; other files (sgxinit.c) get the real
    # declarations from kernel headers via their include chain and would
    # break if we redefine them.
    BCCAT=${S}/services4/3rdparty/bufferclass_ti/bc_cat.c

    if ! grep -q 'OMAP_CPU_COMPAT_STUBS' "$BCCAT"; then
        printf '%s\n' \
            '#ifndef OMAP_CPU_COMPAT_STUBS' \
            '#define OMAP_CPU_COMPAT_STUBS' \
            '#define cpu_is_omap3530() 0' \
            '#define cpu_is_omap3517() 0' \
            '#define omap_rev() 0' \
            '#define OMAP3430_REV_ES3_0 0' \
            '#endif' \
            | cat - "$BCCAT" > "${BCCAT}.tmp"
        mv "${BCCAT}.tmp" "$BCCAT"
    fi

    # --- omaplfb_linux.c: patch removed DSS update-mode API ---
    OMAPLFB=${S}/services4/3rdparty/dc_omapfb3_linux/omaplfb_linux.c

    # Add compat enum definition (provides the type and constants).
    # Uses C-level #ifndef guard so even if prepended more than once the
    # preprocessor only keeps the first definition.
    if ! grep -q 'OMAP_DSS_UPDATE_MODE_COMPAT' "$OMAPLFB"; then
        printf '%s\n' \
            '#ifndef OMAP_DSS_UPDATE_MODE_COMPAT' \
            '#define OMAP_DSS_UPDATE_MODE_COMPAT' \
            'enum omap_dss_update_mode { OMAP_DSS_UPDATE_DISABLED=0, OMAP_DSS_UPDATE_AUTO, OMAP_DSS_UPDATE_MANUAL };' \
            '#endif' \
            | cat - "$OMAPLFB" > "${OMAPLFB}.tmp"
        mv "${OMAPLFB}.tmp" "$OMAPLFB"
    fi

    # Null-check on removed get_update_mode -> always true (early return)
    sed -i 's/psDSSDrv->get_update_mode == NULL/1 /' "$OMAPLFB"
    # Stub the actual call (dead code, but must still compile)
    sed -i 's/eMode = psDSSDrv->get_update_mode(psDSSDev)/eMode = OMAP_DSS_UPDATE_DISABLED/' "$OMAPLFB"

    # Null-check on removed set_update_mode -> always true (early return)
    sed -i 's/psDSSDrv == NULL || psDSSDrv->set_update_mode == NULL/1 /' "$OMAPLFB"
    # Stub the actual call (dead code, but must still compile)
    sed -i 's/res = psDSSDrv->set_update_mode(psDSSDev, eDSSMode)/res = -1/' "$OMAPLFB"
}
