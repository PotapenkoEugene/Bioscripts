#!/bin/bash

### Specified full path to pFSBC (was lazy to add it to PATH)
FASTQ=$1
CPU=$2
SUBSTITUTION=$3
MIN=$4 #min motif len
MAX=$5 #max motif leni

# TRIM (specific options pasted)
fastqTRIM=$(basename $FASTQ .fastq).trim.fastq
fastp -w 16 -a GATCGGAAGAGCACACGTC -b 35 --length_required 35 -i $FASTQ -o $fastqTRIM

# 2fasta
fasta=$(basename $fastqTRIM .fastq).fasta
seqtk seq -a $fastqTRIM > $fasta 

# Rename
fastaRE=$(basename $fasta .fasta).RE.fasta
cat $fasta | awk '/^>/{print ">" ++i; next}{print}' > $fastaRE

# Dedup
conda activate bbmap
fastaREdeDUP=$(basename $fastaRE .fasta).deDup.fasta
clumpify.sh in=$fastaRE out=$fastaREdeDUP dedupe subs=$SUBSTITUTION

# Clustering
conda activate FSBC
python3 /mnt/data/eugene/Tools/pfsbc/pFSBC.py -i $fastaREdeDUP -o FSBC_dedup_$MIN-$MAX -th $CPU -min $MIN -max $MAX
