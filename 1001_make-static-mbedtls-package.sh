#!/bin/bash

# 1001_make-static-mbedtls-package.sh
# 2018-7-6 v1.00

set -e

##### settings #####
PKGBUILD_ORIG=PKGBUILD
PKGBUILD_NEW=PKGBUILD_static
USE_STANDALONE_CMAKE=no
INCLUDE_DOCUMENTS=no

##### functions #####
function usage {
    cat <<"EOF"
Usage: 1001_make-static-mbedtls-package.sh [options]
Options:
    --use-standalone-cmake
        Use standalone cmake instead of Mingw's one.
    --include-documents
        Include document files.
EOF
}

function do_check_file {
    if [ ! -f "$1" ]; then
        echo "File '$1' not found.  Aborting."; exit 1
    fi
}

function do_patch_to_file {
    local patch_file="$2"

    cp "$1" "$patch_file"

    # add static link option
    cp $patch_file $patch_file.bak
    sed -e '/-DUSE_STATIC_MBEDTLS_LIBRARY=ON/a \    -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc" \\' $patch_file.bak > $patch_file

    # use standalone cmake
    if [ "$USE_STANDALONE_CMAKE" = yes ]; then
        # remove dependency to Mingw's cmake
        cp $patch_file $patch_file.bak
        sed -e 's@\("${MINGW_PACKAGE_PREFIX}-cmake"\)@#\1@' $patch_file.bak > $patch_file
        # remove path to cmake
        cp $patch_file $patch_file.bak
        sed -e 's@${MINGW_PREFIX}/bin/cmake@cmake@' $patch_file.bak > $patch_file
    fi

    # not include documents
    if [ ! "$INCLUDE_DOCUMENTS" = yes ]; then
        # remove dependency to doxygen
        cp $patch_file $patch_file.bak
        sed -e 's@\("${MINGW_PACKAGE_PREFIX}-doxygen"\)@#\1@' $patch_file.bak > $patch_file
        # skip make apidoc
        cp $patch_file $patch_file.bak
        sed -e 's@\(make apidoc\)@#\1@' $patch_file.bak > $patch_file
        # skip make directory
        cp $patch_file $patch_file.bak
        sed -e 's@\(mkdir -p "${pkgdir}/${MINGW_PREFIX}/share/doc/${_realname}"\)@#\1@' $patch_file.bak > $patch_file
        # skip copy documents
        cp $patch_file $patch_file.bak
        sed -e 's@\(cp -Rp apidoc "${pkgdir}/${MINGW_PREFIX}/share/doc/${_realname}/html"\)@#\1@' $patch_file.bak > $patch_file
    fi

    rm -f $patch_file.bak
}

##### main #####

while [ "$#" -gt 0 ]; do
    case $1 in
        --use-standalone-cmake)
            USE_STANDALONE_CMAKE=yes; shift;;
        --include-documents)
            INCLUDE_DOCUMENTS=yes; shift;;
        *)  usage; exit 1;;
    esac
done

do_check_file    $PKGBUILD_ORIG
do_patch_to_file $PKGBUILD_ORIG $PKGBUILD_NEW

echo "File '$PKGBUILD_NEW' is generated successfully."
echo -n "Do you want to make package now? [y/N]: "
read ans < /dev/tty
case "$ans" in
    [yY]*) ;;
    *) exit 0;;
esac

makepkg-mingw -f -p "$PKGBUILD_NEW"

echo
echo "Package files are generated successfully."
echo "To install these packages, type as follows."
echo "  pacman -U mingw-w64-xxx-mbedtls-yyy-any.pkg.tar.xz"
echo "(xxx is arch-name. yyy is version.)"

