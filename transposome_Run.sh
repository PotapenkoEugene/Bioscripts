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
IMAGE=$4 # transposome image
THREADS=$5
#############

nameR1=$(basename $R1 .fastq.gz)
R2=$(echo $R1 | sed 's/_R1_/_R2_/g')
nameR2=$(basename $R2 .fastq.gz)

echo Sampling
seqtk sample -s 42 $R1 ${FRACTION} > ${nameR1}_${FRACTION}.fastq
seqtk sample -s 42 $R2 ${FRACTION} > ${nameR2}_${FRACTION}.fastq

# Count number of sampled reads:
READNUM=`expr $(cat ${nameR1}_${FRACTION}.fastq | wc -l) / 4`

echo  Trimming
fastp -w ${THREADS} -i ${nameR1}_${FRACTION}.fastq -I ${nameR2}_${FRACTION}.fastq -o ${nameR1}_${FRACTION}.trim.fastq -O ${nameR2}_${FRACTION}.trim.fastq -l 50 && rm ${nameR1}_${FRACTION}.fastq ${nameR2}_${FRACTION}.fastq

echo Restore pairing information # !!!! CAN BE SKIPPED IF DATA NOT FROM SRA !!!!
#pairfq addinfo -i ${name}1.${FRACTION}.trim.fastq -o ${name}1.${FRACTION}.trim.peinfo.fastq  -p 1 && rm ${name}1.${FRACTION}.trim.fastq # add -c gzip for archieving
#pairfq addinfo -i ${name}2.${FRACTION}.trim.fastq -o ${name}2.${FRACTION}.trim.peinfo.fastq -p 2 && rm ${name}2.${FRACTION}.trim.fastq

echo  Interveal
pairfq joinpairs -f ${nameR1}_${FRACTION}.trim.fastq -r ${nameR2}_${FRACTION}.trim.fastq -o ${nameR1}_${FRACTION}.intervealed.fastq && rm ${nameR1}_${FRACTION}.trim.fastq ${nameR2}_${FRACTION}.trim.fastq


mkdir -p configs transposome_out
echo "blast_input:
  - sequence_file:      ${nameR1}_${FRACTION}.intervealed.fastq
  - sequence_format:    fastq
  - thread:             ${THREADS}
  - output_directory:   transposome_out/${nameR1}_${FRACTION}
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
  - cluster_log_file:   t_cluster_report.txt" > configs/${nameR1}_${FRACTION}.yml

echo Transposome

source ${CONDA_PREFIX}/etc/profile.d/conda.sh

conda activate singularity

singularity exec -H `pwd` $IMAGE transposome --config configs/${nameR1}_${FRACTION}.yml

conda deactivate

python3 /mnt/data/eugene/Tools/Bioscripts/TransposomeFamilyAnalyse.py transposome_out/${nameR1}_${FRACTION}/t_cluster_report_singletons_annotations_summary.tsv ${DB} ${READNUM}
