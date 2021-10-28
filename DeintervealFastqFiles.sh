#!/bin/bash
source ${CONDA_PREFIX}/etc/profile.d/conda.sh

conda activate repeatprof

INTERVEALED=$@
for read in $INTERVEALED
	do
	name=$(basename -s .fastq -s .fq -s .fastq.gz -s .fq.gz $read)
	reformat.sh in=$read out1=${name}_R1.fastq out2=${name}_R2.fastq
	done

