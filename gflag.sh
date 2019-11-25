#!/bin/bash

if [[ -z "${2}" ]] ; then
	ARCH="native"
else
	ARCH="${2}"
fi

if [[ -z "${3}" ]] ; then
	opt="-O"
else
	opt="-O${3}" # Possible values: 0 g s 1 2 3 fast
fi

all_help=('adascil' 'common' 'joined' 'optimizers'
	'undocumented' 'adawhy' 'fortran' 'lto' 'params' 'warnings'
	'c' 'go' 'objc' 'separate' 'ada' 'c++' 'objc++' 'target')

tune() {
	ARCH="native"
	gcc -mtune=${ARCH} -E -v - </dev/null 2>&1 | grep cc1 | sed 's/.*v\ -\ //g ; s/param\ /param=/g'
}

arch() {
	ARCH="native"
	gcc -march=${ARCH} -E -v - </dev/null 2>&1 | grep cc1 | sed 's/.*v\ -\ //g ; s/param\ /param=/g'
}

macro() {
	gcc -march=${ARCH} ${opt} -dM -E - </dev/null | sed 's/\#define\ /\-D/g ; s/\ /=/g' | sort | column
}

macroplus() {
	g++ -march=${ARCH} ${opt} -dM -E -x c++ - </dev/null | sed 's/\#define\ /\-D/g ; s/\ /=/g' | sort | column
}

m32() {
#	diff -y --suppress-common-lines \
#	<(macro) <(ARCH="${ARCH} -m32" macro) # column breaks output

	for x in "${all_help[@]}"; do
		diff -y --suppress-common-lines \
		<(gcc -Q -march=${ARCH} ${opt} --help=${x} | sort) \
		<(gcc -Q -march=${ARCH} -m32 ${opt} --help=${x} | sort)
	done
}


	case "${1}" in
		'tune'|'mtune')
			tune
		;;
		'arch'|'march')
			arch
		;;
		'macro'|'mackerel')
			macro
		;;
		'macro++'|'mackerel++')
			macroplus
		;;
		'32'|'m32') # compare opts for 32bit compat flags
			m32
		;;
		*)
			echo -e " Usage syntax: [tune,arch,macro,macro++,32] [architecture] [opt-level]"
			echo -e " Example: ./gflag.sh macro native fast | ./gflag.sh tune\n"
			echo -e " tune/arch do not accept [architecture] [opt-level] due to 'gcc -E'"
			echo -e " If no argument is passed for [architecture], defaults to -march=native"
			echo -e " If no argument is passed for [opt], defaults to -O"
	esac


#!/bin/bash


