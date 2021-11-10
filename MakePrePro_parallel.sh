#!/bin/bash

##############
FILEPATHS=$1
THREADS=$2
OUTFILE=$3
##############

for i in `cat $FILEPATHS`;
        do
        echo "PrePro_RepEx.sh $i 750000 1"
        done > $OUTFILE
