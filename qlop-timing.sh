#!/bin/bash

export catapackage="${1}"

case "${1}" in
	''|'--help'|'-h'|'--usage')
		echo -e " Usage: Enter a package or category as an argument to"
		echo -e "	receive the approximate time it will take to compile." ; exit 0
esac

pategory() {
# How to determine package vs. category? With unreadable code
	if [[ -d /var/db/repos/gentoo ]] ; then
		everything=($(ls /var/db/repos/gentoo -w1 | tr -d '/'))
		for i in "${everything[@]}" ; do
			if [ "${catapackage}" == "${i}" ] ; then
				export catapackage+="/"
			fi
		done
	elif [[ -d /usr/portage ]] ; then
		echo -e "You are using the deprecated directory for the Portage tree.\nWe don't do that here around these parts of town"
	else
	echo "Can't find your Portage tree, continuing but expect errors"
	fi
}

pkg_check() {
# Checks if you have ever emerged the catapackage on this system before

	if [[ -z $(qlop -q "${catapackage}") ]] ;
then
	echo -e "Package nor category seems to exist. ABORTING" ; exit 127
	fi
}

magic() {
# Determines if the input is a package or category and chooses the proper format to use

	case ${catapackage} in
		*/*)
			qlop -mtM ${catapackage} | awk '{ print  (NR $4/NR)/60/60 }' | (echo -e "Compiling the \e[38;5;202m${catapackage}\e[0m category should take approximately \e[38;5;82m$(tail -n1) hours")
		;;
		*)
			qlop -mtM ${catapackage} | sort -nrk1 | awk '{sum += $4} END { print (sum/NR/60) }' | (echo -e "Compiling \e[38;5;202m${catapackage}\e[0m should take approximately \e[38;5;82m$(tail -n1) minutes")
			#			   sort is not needed but I want to implement its use later
	esac
}

pategory
pkg_check
magic


#TODO: intended to grab the longest taking pkg
#qlop -mtM ${catapackage} | sort -nrk1 | awk '{ print $4 }' | (echo "$(tail -n1)/60") | bc


# This didn't work?
#qlop -acmM dev-qt/ | tail -n1 | awk '{ print int( $2/$4/60 ) }'
#qlop -M sys-devel/ | sed 's/.*\///g' |  sort -t:  -nk2 | rev | uniq -f 1

