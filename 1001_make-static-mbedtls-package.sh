#!/bin/bash

# 1001_make-static-mbedtls-package.sh
# 2018-7-12 v1.05

set -e

##### settings #####
MINGW_PKGS_URL=https://github.com/Alexpux/MINGW-packages/archive/master.tar.gz
MINGW_PKGS_TARBALL=MINGW-packages.tar.gz
TARGET_PKG_DIR=MINGW-packages-master/mingw-w64-mbedtls

PKGBUILD_ORIG=PKGBUILD
PKGBUILD_NEW=PKGBUILD_static1001
MAKEPKG=makepkg-mingw

USE_STANDALONE_CMAKE=no
INCLUDE_DOCUMENTS=no
SKIP_DOWNLOAD=no
PAUSE_BEFORE_MAKEPKG=no

##### functions #####
function usage {
    echo "Usage: 1001_make-static-mbedtls-package.sh [options]"
    echo "Options:"
    echo "    --use-standalone-cmake"
    echo "        Use standalone CMake instead of Mingw's one."
    echo "    --include-documents"
    echo "        Include document files."
    echo "    --skip-download"
    echo "        Skip download '$MINGW_PKGS_TARBALL'"
    echo "    --pause-before-makepkg"
    echo "        Pause before calling '$MAKEPKG'."
}

function do_download {
    if [ ! "$SKIP_DOWNLOAD" = yes ]; then
        if ! curl -f -L --progress-bar -o "$1" "$2"; then
            echo "Download '$1' failed.  Aborting."; exit 1
        fi
    fi
}

function do_extract {
    if ! tar xvfz "$1" "$2"; then
        echo "Extract '$1' failed.  Aborting."; exit 1
    fi
}

function do_check_file {
    if [ ! -f "$1" ]; then
        echo "File '$1' not found.  Aborting."; exit 1
    fi
}

function do_patch_to_file {
    local patch_file="$2"
    local bak="bak5001"

    cp "$1" "$patch_file"

    # add static link option
    cp $patch_file $patch_file.$bak
    sed -e '/-DUSE_STATIC_MBEDTLS_LIBRARY=ON/a \    -DCMAKE_SHARED_LINKER_FLAGS="-static-libgcc" \\' $patch_file.$bak > $patch_file

    # use standalone CMake
    if [ "$USE_STANDALONE_CMAKE" = yes ]; then
        # remove dependency to Mingw's CMake
        cp $patch_file $patch_file.$bak
        sed -e 's@\("${MINGW_PACKAGE_PREFIX}-cmake"\)@#\1@' $patch_file.$bak > $patch_file
        # remove path to CMake
        cp $patch_file $patch_file.$bak
        sed -e 's@${MINGW_PREFIX}/bin/cmake@cmake@' $patch_file.$bak > $patch_file
    fi

    # not include documents
    if [ ! "$INCLUDE_DOCUMENTS" = yes ]; then
        # remove dependency to Doxygen
        cp $patch_file $patch_file.$bak
        sed -e 's@\("${MINGW_PACKAGE_PREFIX}-doxygen"\)@#\1@' $patch_file.$bak > $patch_file
        # skip 'make apidoc'
        cp $patch_file $patch_file.$bak
        sed -e 's@\(make apidoc\)@#\1@' $patch_file.$bak > $patch_file
        # skip making directory
        cp $patch_file $patch_file.$bak
        sed -e 's@\(mkdir -p "${pkgdir}/${MINGW_PREFIX}/share/doc/${_realname}"\)@#\1@' $patch_file.$bak > $patch_file
        # skip copying documents
        cp $patch_file $patch_file.$bak
        sed -e 's@\(cp -Rp apidoc "${pkgdir}/${MINGW_PREFIX}/share/doc/${_realname}/html"\)@#\1@' $patch_file.$bak > $patch_file
    fi

    rm -f $patch_file.$bak
}

##### main #####

while [ "$#" -gt 0 ]; do
    case $1 in
        --use-standalone-cmake)
            USE_STANDALONE_CMAKE=yes; shift;;
        --include-documents)
            INCLUDE_DOCUMENTS=yes; shift;;
        --skip-download)
            SKIP_DOWNLOAD=yes; shift;;
        --pause-before-makepkg)
            PAUSE_BEFORE_MAKEPKG=yes; shift;;
        *)  usage; exit 1;;
    esac
done

do_download $MINGW_PKGS_TARBALL $MINGW_PKGS_URL
do_extract  $MINGW_PKGS_TARBALL $TARGET_PKG_DIR

pwd_old=`pwd`
cd $TARGET_PKG_DIR

do_check_file    $PKGBUILD_ORIG
do_patch_to_file $PKGBUILD_ORIG $PKGBUILD_NEW

echo "File '$PKGBUILD_NEW' was generated successfully."
if [ "$PAUSE_BEFORE_MAKEPKG" = yes ]; then
    echo -n "Do you want to make package now? [y/N]: "
    read ans < /dev/tty
    case "$ans" in
        [yY]*) ;;
        *) exit 0;;
    esac
fi

$MAKEPKG -f -p $PKGBUILD_NEW

cp -f *.pkg.tar.xz "$pwd_old"
cd "$pwd_old"

echo
echo "Package files were generated successfully."
echo "To install these packages, type as follows."
echo "  pacman -U mingw-w64-xxx-mbedtls-yyy-any.pkg.tar.xz"
echo "(xxx is arch-name. yyy is version.)"

