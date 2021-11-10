#!/bin/bash

#############
R1=$1
FRACTION=$2
THREADS=$3
#############

nameR1=$(basename $R1 .fastq.gz)
R2=$(echo $R1 | sed 's/_R1/_R2/g')
nameR2=$(basename $R2 .fastq.gz)

echo START

echo INFO: Work with $R1 and $R2 pair

echo FRACTION: $FRACTION

echo INFO: Sampling
time (echo "seqtk sample -s 42 $R1 ${FRACTION} > ${nameR1}_${FRACTION}.fastq" ; echo "seqtk sample -s 42 $R2 ${FRACTION} > ${nameR2}_${FRACTION}.fastq") | parallel

echo  INFO: Trimming
fastp -w $THREADS -i ${nameR1}_${FRACTION}.fastq -I ${nameR2}_${FRACTION}.fastq -o ${nameR1}_${FRACTION}.trim.fastq -O ${nameR2}_${FRACTION}.trim.fastq -l 50 && rm ${nameR1}_${FRACTION}.fastq ${nameR2}_${FRACTION}.fastq

echo  INFO: Interveal
pairfq joinpairs -f ${nameR1}_${FRACTION}.trim.fastq -r ${nameR2}_${FRACTION}.trim.fastq -o ${nameR1}_${FRACTION}.intervealed.fastq  && rm ${nameR1}_${FRACTION}.trim.fastq ${nameR2}_${FRACTION}.trim.fastq

echo INFO: ToFasta
any2fasta ${nameR1}_${FRACTION}.intervealed.fastq > ${nameR1}_${FRACTION}.intervealed.fa && rm ${nameR1}_${FRACTION}.intervealed.fastq

echo END

