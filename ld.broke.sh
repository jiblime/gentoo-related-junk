#!/bin/bash

# For use with app-portage/portage-bashrc-mv from the mv overlay.
# If a package fails to build with LLD, run this and input the category/package and possible reason.
# This will add it to a filter list and switch to the default BFD. If, for some reason, you think
# that the speed of linking with LLD makes up for the time spent making per-package CFLAGS every 5min.
# Default package input is the last package emerged and can be deleted and replaced.

export LAST=$(awk 'f{print;f=0} /"favorites": \[/{f=1}' /var/cache/edb/mtimedb | tr -d '"' | tr -d [:blank:] | head -n1)

if [[ $LAST == @* ]]; then
        unset LAST
fi

read -p "Package that broke? " -i "${LAST}" -e GDI

printf "Reason? "
read DOC

echo -e "\n#  "${DOC}"" >> /etc/portage/package.cflags/clang-lld.conf

echo "${GDI}" >> /etc/portage/package.cflags/clang-lld.conf

sed -i '$s/$/\ \*FLAGS\-\=\"\-fuse\-linker\-plugin\ \-fuse\-ld\=lld\"/' /etc/portage/package.cflags/clang-lld.conf

echo "${GDI}" >> /etc/portage/package.cflags/clang-lld.conf

sed -i '$s/$/\ \*FLAGS\+\=\"\-fuse\-ld\=bfd\"/' /etc/portage/package.cflags/clang-lld.conf
