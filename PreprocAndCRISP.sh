#!/bin/bash

####### 
# SCRIPT MUST BE IN FOLDER WITH READS
# Pos arguments:
# 2) Path to reference genome
# 3) Thread number
# 4) max RAM
#######

GENOME=$1
THREADS=$2
RAM=${3}G # NOT NEED?

# Можно добавить файл с SRRs
#for srr in $SRRs
#do
#prefetch $srr -o .
#fastq-dump --split-3 $srr.sra && rm $srr.sra # не уверен в каком формате скачивает prefetch
#gzip ${srr}_1.fastq ${srr}_2.fastq
#done

# index genome
#samtools faidx $GENOME
echo 'Genome fasta indexed'
# must be only one dot in GENOME name (standart from NCBI refseq or genbank)
BWAINDEX=$(echo $GENOME| cut -f1 -d '.') # remove format
#bwa index $GENOME -p $BWAINDEX
echo 'Got bwa index'

QC_OUTDIR='QC'

mkdir QC fastp alignment
for file in *_1.fastq.gz # take in cycle only one of pair
do
echo $file
basename=$(echo ${file} | cut -f1 -d '_') # standart SRR splitted PE read needed
FL1=${basename}_1.fastq.gz
FL2=${basename}_2.fastq.gz

echo $FL1 $FL2
# Make QC
fastqc -t $THREADS -o $QC_OUTDIR  $FL1 $FL2 
fastp -i $FL1 -I $FL2 -o fastp/${basename}_1.tr.fq.gz -O fastp/${basename}_2.tr.fq.gz -w && rm $FL1 $FL2 $THREADS
echo 'Fastp ${basename} done'
done

R1TRIMMED='fastp/*_1.tr.fq.gz'
 
for file in $R1TRIMMED
do
basename=$(echo $file | rev | cut -f1 -d '/'| rev| cut -f1 -d '_')
FL1=${basename}_1.tr.fq.gz # basename with path to file
FL2=${basename}_2.tr.fq.gz
# Make QC
fastqc $FL1 $FL2 -t $THREADS -o $QC_OUTDIR
# ALIGN -P for paired, -M for mark shorter splits (needed for Picard)
bwa mem -t $THREADS -P -M $GENOME  $FL1 $FL2 > alignment/${basename}.sam && rm $FL1 $FL2
echo 'Aligned ${basename}'
# convert to bam

samtools view -@ $THREADS -b -F 4 -q 15 alignment/${basename}.sam | samtools sort -@ $THREADS > alignment/${basename}.bam && rm alignment/${basename}.sam
echo 'Converted to bam ${basename}'
# fill in mate coordinates, ISIZE and mate related flags from a name-sorted alignment
samtools fixmate -@ $THREADS alignment/${basename}.bam alignment/${basename}.fm.bam && rm alignment/{$basename}.bam
echo 'Fixed mates ${basename}'
# By default works for PE -fr (for SE -s)
samtools rmdup -@ $THREADS alignment/${basename}.fm.bam alignment/${basename}.ddp.bam && rm alignment/{$basename}.fm.bam
echo 'Removed dups ${basename}'
# Take map statistics
samtools flagstat -@ $THREADS alignment/${basename}.ddp.bam > ${QC_OUTDIR}/${basename}.flagstat
echo 'Get flagstats ${basename}'
done

# Run CRISP.binary on all bam files, poolsize for diploids (2 x individuals)
#CRISP.binary --bams alignment/*.ddp.bam --ref $GENOME --poolsize 
