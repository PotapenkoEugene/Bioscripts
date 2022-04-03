#!/bin/bash

# Run in WORKDIR
#####################
R1=$1 # ChIPSeq_ES_2_CGATGT_L001_R1_001.fastq
R2=$2 # ChIPSeq_ES_2_CGATGT_L001_R2_001.fastq
BARCODES=$3 # NAME1 BARCODE1 (.tsv)
MISMATCH=$4 # 5 norm!

CPU=$5
#####################

R1name=${R1%%.*}
R2name=${R2%%.*}
mkdir QC trim

# QC raw reads
fastqc $R1 $R2 -t $CPU -o QC

# Trim first NNN
fastp -w $CPU -f 3 -i $R1 -I $R2 -o trim/${R1name}.trim.fastq.gz -O trim/${R2name}.trim.fastq.gz

cd trim
R1=${R1name}.trim.fastq.gz
R2=${R2name}.trim.fastq.gz

# BarcodeSplit

zcat $R1 | BarcodeSplitter --bcfile $BARCODES --bol --mismatch $MISMATCH --prefix BarSplitR1/ --suffix ".fastq"
zcat $R2 | BarcodeSplitter --bcfile $BARCODES --bol --mismatch $MISMATCH --prefix BarSplitR2/ --suffix ".fastq"

