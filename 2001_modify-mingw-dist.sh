#!/bin/bash

# 2001_modify-mingw-dist.sh
# 2018-7-6 v1.01

set -e

##### settings #####
MINGW_DIST_FILE=src/mingw-dist.sh
MINGW_DIST_BKUP=src/mingw-dist_orig.sh
MBEDTLS_DLL="libmbedcrypto.dll libmbedtls.dll libmbedx509.dll"

##### functions #####
function usage {
    cat <<"EOF"
Usage: 2001_modify-mingw-dist.sh
EOF
}

function do_check_file {
    if [ ! -f "$1" ]; then
        echo "File '$1' not found.  Aborting."; exit 1
    fi
}

function do_backup_file {
    if [ ! -f "$2" ]; then
        cp "$1" "$2"
    fi
}

function do_patch_to_file {
    local patch_file="$1"
    local sed_text1
    local sed_text2

    # add configure option
    if ! grep -q -e '--with-tls=axtls,mbedtls' $patch_file; then
        cp $patch_file $patch_file.bak
        sed -e 's@\(--with-tls=axtls\)@\1,mbedtls@' $patch_file.bak > $patch_file
    fi

    # add library files
    if ! grep -q -e "$MBEDTLS_DLL" $patch_file; then
        cp $patch_file $patch_file.bak
        sed_text1='s@\(libwinpthread-1.dll\)@\1 '
        sed_text2='@'
        sed -e "$sed_text1$MBEDTLS_DLL$sed_text2" $patch_file.bak > $patch_file
    fi

    rm -f $patch_file.bak
}

##### main #####

while [ "$#" -gt 0 ]; do
    case $1 in
        *) usage; exit 1;;
    esac
done

do_check_file    $MINGW_DIST_FILE
do_backup_file   $MINGW_DIST_FILE $MINGW_DIST_BKUP
do_patch_to_file $MINGW_DIST_FILE

echo "File '$MINGW_DIST_FILE' is modified successfully."

