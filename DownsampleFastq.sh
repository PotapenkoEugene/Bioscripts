#!/bin/bash

# Downsample fastq

#############
R1=$1
FRACTION=$2
#############

nameR1=$(basename $R1 .fastq.gz)
dir=$(dirname $R1)

R2=$(echo $R1 | sed 's/_R1_/_R2_/g')
nameR2=$(basename $R2 .fastq.gz)

echo Sampling
seqtk sample -s 42 $R1 ${FRACTION} > ${nameR1}_${FRACTION}.fastq
seqtk sample -s 42 $R2 ${FRACTION} > ${nameR2}_${FRACTION}.fastq

