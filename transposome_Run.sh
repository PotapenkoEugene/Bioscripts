#!/bin/bash

# Specifying CONFIGNAME and basic options
# Have to be in the same directory:
# 1) TransposomeFamilyAnalyses.py 
# 2) transposome_latest.sif (singularity container build via pull)
# 3) singularity conda enviroment

#############
R1=$1
FRACTION=$2
DB=$3
THREADS=$4
#############

name=$(basename $R1 1.fastq)
dir=$(dirname $R1)

R2="${dir}/${name}2.fastq"

echo Sampling
seqtk sample -s 42 $R1 ${FRACTION} > ${name}1.${FRACTION}.fastq
seqtk sample -s 42 $R2 ${FRACTION} > ${name}2.${FRACTION}.fastq

echo  Trimming
fastp -w 16 -i ${name}1.${FRACTION}.fastq -I ${name}2.${FRACTION}.fastq -o ${name}1.${FRACTION}.trim.fastq -O ${name}2.${FRACTION}.trim.fastq -l 50 && rm ${name}1.${FRACTION}.fastq ${name}2.${FRACTION}.fastq

echo Restore pairing information # !!!! CAN BE SKIPPED IF DATA NOT FROM SRA !!!!
pairfq addinfo -i ${name}1.${FRACTION}.trim.fastq -o ${name}1.${FRACTION}.trim.peinfo.fastq  -p 1 && rm ${name}1.${FRACTION}.trim.fastq # add -c gzip for archieving
pairfq addinfo -i ${name}2.${FRACTION}.trim.fastq -o ${name}2.${FRACTION}.trim.peinfo.fastq -p 2 && rm ${name}2.${FRACTION}.trim.fastq

echo  Interveal
pairfq joinpairs -f ${name}1.${FRACTION}.trim.peinfo.fastq -r ${name}2.${FRACTION}.trim.peinfo.fastq -o ${name}.${FRACTION}.intervealed.fastq && rm ${name}1.${FRACTION}.trim.peinfo.fastq ${name}2.${FRACTION}.trim.peinfo.fastq


mkdir -p configs transposome_out
echo "blast_input:
  - sequence_file:      ${name}.${FRACTION}.intervealed.fastq
  - sequence_format:    fastq
  - thread:             ${THREADS}
  - output_directory:   transposome_out/${name}_${FRACTION}
clustering_options:
  - in_memory:          1
  - percent_identity:   90
  - fraction_coverage:  0.55
annotation_input:
  - repeat_database:    ${DB}
annotation_options:
  - cluster_size:       100
output:
  - run_log_file:       t_log.txt
  - cluster_log_file:   t_cluster_report.txt" > configs/${name}_${FRACTION}.yml

echo Transposome

source ${CONDA_PREFIX}/etc/profile.d/conda.sh

conda activate singularity

singularity exec -H `pwd` transposome_latest.sif transposome --config configs/${name}_${FRACTION}.yml

conda deactivate

python3 TransposomeFamilyAnalyses.py transposome_out/${name}_${FRACTION}/t_cluster_report_singletons_annotations_summary.tsv ${DB} ${FRACTION}
