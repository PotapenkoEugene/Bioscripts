#!/bin/bash

#############
R1=$1
FRACTION=$2 # Or NUMBER OF READS
MINLEN=$3
THREADS=$4
#############

nameR1=$(basename $R1 .fastq.gz)

echo START

echo INFO: Work with $R1

echo FRACTION: $FRACTION

echo INFO: Sampling
seqtk sample -s 42 $R1 ${FRACTION} > ${nameR1}_${FRACTION}.fastq

echo  INFO: Trimming
fastp -w $THREADS -i $R1 -o ${nameR1}.trim.fastq -l $MINLEN

echo INFO: Sampling
seqtk sample -s 42 ${nameR1}.trim.fastq > ${nameR1}_${FRACTION}.trim.fastq && rm ${nameR1}.trim.fastq


