#!/bin/bash

# For use with app-portage/portage-bashrc-mv from the mv overlay.
# If a package fails to build with LLD, run this and input the category/package and possible reason.
# This will add it to a filter list and switch to the default BFD. If, for some reason, you think
# that the speed of linking with LLD makes up for the time spent making per-package CFLAGS every 5min.
# Default package input is the last package emerged (if it is not a @set) and can be deleted and replaced.

edit_conf()
{
printf "\033[1A"
cd /etc/portage/package.cflags

local  VAR=( {a..z} ); local CONF=( $(ls) )

for i in "${!CONF[@]}"; do    local "${VAR[i]}=${CONF[i]}"; done

for i in "${!CONF[@]}"; do    echo  "$i -- ${CONF[i]}"; done

echo -e "\nChoose the conf file to append to: \c"

read CHOICE

messy="${CONF[$CHOICE]}"
}


pkg_guess()
{
export LAST=$(awk 'f{print;f=0} /"favorites": \[/{f=1}' /var/cache/edb/mtimedb | tr -d '"' | tr -d [:blank:] | head -n1)

if [[ $LAST == @* ]]; then
        unset LAST
fi
}

pkg_guess

read -p "Package to filter: " -i "$LAST" -e GDI
printf "\033[1A"
echo -e "\033[KReason? \c"
read DOC

edit_conf
echo -e "\n${GDI}\c" >> /etc/portage/package.cflags/${messy}

sed -i '$s/$/\ \*FLAGS\-\=\"\-fuse\-linker\-plugin\ \-fuse\-ld\=gold\ \-fuse\-ld\=lld\"/' /etc/portage/package.cflags/${messy}

echo " # "${DOC}"" >> /etc/portage/package.cflags/"${messy}"


echo "${GDI}" >> /etc/portage/package.cflags/"${messy}"

sed -i '$s/$/\ \*FLAGS\+\=\"\-fuse\-ld\=bfd\"/' /etc/portage/package.cflags/${messy}
