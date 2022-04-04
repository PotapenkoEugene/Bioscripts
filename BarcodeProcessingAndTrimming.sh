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

R1trim=${R1name}.trim.fastq.gz
R2trim=${R2name}.trim.fastq.gz
mkdir QC trim

# QC raw reads
#fastqc $R1 $R2 -t $CPU -o QC

# Trim first NNN
if test -f "trim/${R1trim}"; then
	echo "File trim/${R1trim} already exist - SKIP TRIMMING"
else
	fastp -w $CPU -f 3 -i $R1 -I $R2 -o trim/${R1trim} -O trim/${R2trim}
fi

cd trim

# BarcodeSplit
mkdir BarSplitR1 BarSplitR2

(echo "zcat $R1trim | BarcodeSplitter --bcfile ../${BARCODES} --bol --mismatches $MISMATCH --prefix BarSplitR1/ --suffix "_R1.fastq" --debug"
 echo "zcat $R2trim | BarcodeSplitter --bcfile ../${BARCODES} --bol --mismatches $MISMATCH --prefix BarSplitR2/ --suffix "_R2.fastq" --debug") | parallel

