#!/bin/bash
FILE=$1
COLUMN=$2
NUMERIC=$3 

if [ "${NUMERIC}" = "n" ]; then
  (head -n 1 ${file} && tail -n +2 ${file} | sort -t $'\t' -nk${COLUMN},${COLUMN})
else
  (head -n 1 ${file} && tail -n +2 ${file} | sort -t $'\t' -k${COLUMN},${COLUMN})
fi

