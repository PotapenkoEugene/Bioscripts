#!/bin/bash
FILE=$1 #tsv file
COLUMN=$2
NUMERIC=$3 

if [ "${NUMERIC}" = "n" ]; then
	( head -n 1 ${FILE} && tail -n +2 ${FILE} | sort -t $'\t' -gk ${COLUMN},${COLUMN} ) #g for include scientific notation
else
	( head -n 1 ${FILE} && tail -n +2 ${FILE} | sort -t $'\t' -k ${COLUMN},${COLUMN} )
fi

