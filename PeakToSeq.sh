#!/bin/bash
# EXAMPLE: 
# PeakToSeq.sh "*narrowPeak" 50 /media/gene/Samsung_T51/GENOMES/mm10/mm10.fa FASTA
PEAKS=$1
HALFLEN=$2
GENOME=$3
OUTDIR=$4 # without SLASH!

mkdir -p "${OUTDIR}"
for i in $PEAKS; do sort -k9nr $i > ${OUTDIR}/$i.sorted; done
for i in ${OUTDIR}/*.sorted; do awk -v halflen="$HALFLEN" 'BEGIN{ OFS="\t";}{ midPos=$2+$10; print $1, midPos-halflen, midPos+halflen; }' $i | uniq > $i.centred;  done
for i in ${OUTDIR}/*centred; do fastaFromBed -fi $GENOME -bed $i -fo $i.fa; head -2000 $i.fa > $i.H1000.fa; done
