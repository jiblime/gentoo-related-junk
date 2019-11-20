#!/bin/bash

	case "${1}" in
		'tune'|'mtune')
			gcc -mtune=native ${opt} -E -v - </dev/null 2>&1 | grep cc1 | sed 's/.*v\ -\ //g ; s/param\ /param=/g'
		;;
		'arch'|'march')
			gcc -march=native ${opt} -E -v - </dev/null 2>&1 | grep cc1 | sed 's/.*v\ -\ //g ; s/param\ /param=/g'
		;;
		'macro'|'mackerel')
			gcc -march=native ${opt} -dM -E - </dev/null | sed 's/\#define\ /\-D/g ; s/\ /=/g' | sort | column
		;;
		'macro++'|'mackerel++')
			g++ -march=native ${opt} -dM -E -x c++ - </dev/null | sed 's/\#define\ /\-D/g ; s/\ /=/g' | sort | column
		;;
		*)
			echo -e " Usage: ./gflag.sh [tune,arch,macro,macro++]\n	-march will always default to native"
	esac
