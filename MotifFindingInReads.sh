#!/bin/bash

### Specified full path to pFSBC (was lazy to add it to PATH)
FASTQ=$1
CPU=$2
SUBSTITUTION=$3
MIN=$4 #min motif len
MAX=$5 #max motif leni

source ${CONDA_PREFIX}/etc/profile.d/conda.sh 

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

# Motif finding
conda activate meme
meme $fastaREdeDUP -dna -oc . -nostatus -time 14400 -mod zoops -nmotifs 3 -minw $MIN -maxw $MAX -objfun classic -revcomp -markov_order 0
