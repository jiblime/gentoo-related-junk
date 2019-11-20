#!/bin/bash
# This works by signing every module in the installed directory and isn't the best way if you're concerned about rogue modules


# Automatically sign modules post-installation for kernels
# built with CONFIG_MODULE_SIG and CONFIG_MODULE_SIG_FORCE.
# Used with app-portage/portage-bashrc-mv from 'mv' overlay.
# Placed in /etc/portage/bashrc.d/

modsign_check() {
# Check if a linux-mod.eclass function exists. If it does, continue.
# There should be a better way to do this...
	declare -f linux-mod_pkg_setup >/dev/null && modsign_env || return
}

modsign_env()
{
	if [[ -n $(grep CONFIG_MODULE_SIG=y /usr/src/linux/.config) ]]; then
		elog 'Signing installed modules.';
	else
		einfo 'CONFIG_MODULE_SIG is not set. Skipping module signing.' && return
	fi

# sig_kpem and sig_cert should be adjusted for
# non-standard locations or names, if needed.
# Below are the generated defaults.

	export $(grep CONFIG_MODULE_SIG_HASH /usr/src/linux/.config | tr -d '"')
	sig_hash="
		/usr/src/linux/scripts/sign-file \
		${CONFIG_MODULE_SIG_HASH}"
	sig_kpem="
		/usr/src/linux/certs/signing_key.pem"
	sig_cert="
		/usr/src/linux/certs/signing_key.x509"

	sig_done="${sig_hash} ${sig_kpem} ${sig_cert}"
	modsign_postinst
}

modsign_postinst()
{
#	/var/db/repos/gentoo/eclass/linux-mod.eclass
        local libdir srcdir objdir i n

        [[ -n ${KERNEL_DIR} ]] && addpredict "${KERNEL_DIR}/null.dwo"

        strip_modulenames;
        for i in ${MODULE_NAMES}
        do
                unset libdir srcdir objdir
                for n in $(find_module_params ${i})
                do
                        eval ${n/:*}=${n/*:/}
                done
                libdir=${libdir:-misc}
	done

	for mod_tosign in $(ls /lib/modules/${KV_FULL}/${libdir}/*); do
		${sig_done} ${mod_tosign} && [[ "${?}" -eq 0 ]] &&
		einfo "${mod_tosign} was signed." ||
		eerror "${mod_tosign} wasn't signed. Sign the module manually if this isn't expected behavior."
	done
}

BashrcdPhase postinst modsign_check

# To get the directory and module names that should be signed,
# use app-portage/gentoolkit to view its installed location or ebuild.
# equery f ${CATEGORY}/${PN} | grep '/lib/modules/.*/' | sed 's/\/.*\///g'
# nano $(equery w ${CATEGORY/${PN})

# Example: $ equery f nvidia-drivers | grep '/lib/modules/.*/' | sed 's/\/.*\///g'
# video
# nvidia-drm.ko
# nvidia-modeset.ko
# nvidia-uvm.ko
# nvidia.ko

# Use hexdump -C /usr/lib/modules/kernel_version/module_dir/module.ko | tail
# to verify that it has been signed.
