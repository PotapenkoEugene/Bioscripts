#!/bin/bash
FILE=$1
CHAR=$2
NEWCHAR=$3

name="${FILE%%.*}"
echo $name
cat $FILE | sed "/^>/! s/${CHAR}/${NEWCHAR}/g" > ${name}.SeqCharReplace.fa
