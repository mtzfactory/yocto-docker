# Google Code shut down in 2016; fetch from GitHub mirror instead.
SRC_URI = "git://github.com/vim/vim.git;protocol=https \
           file://disable_acl_header_check.patch;patchdir=.. \
           file://vim-add-knob-whether-elf.h-are-checked.patch;patchdir=.. \
"
SRCREV = "c8836f702532b0bc3dd16972e6b504a7340e90e2"
S = "${WORKDIR}/git/src"
