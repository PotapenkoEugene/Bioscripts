#!/bin/bash

#############
R1=$1
FRACTION=$2
CLASS=$3 # file with classification of Viridiplantae3.0 db
THREADS=$4
#############

nameR1=$(basename $R1 .fa)

echo START

echo INFO: Start RepeatExplorer2 analysis

mkdir -p "TEMP_${nameR1}_${FRACTION}" # TEMP dir in cur dir

source ${CONDA_PREFIX}/etc/profile.d/conda.sh
conda activate singularity

SINGULARITY_TMPDIR=/mnt/data/eugene/SINGULARITY/tmp SINGULARITY_CACHEDIR=/mnt/data/eugene/SINGULARITY/cache singularity exec -W . --bind ${PWD}:/data/ /mnt/data/eugene/Tools/repex_tarean_latest.sif /bin/bash -c "export TEMP=/data/TEMP_${nameR1}_${FRACTION}; seqclust -tax VIRIDIPLANTAE3.0 -c ${THREADS} -p -C -l /data/REout_${nameR1}_${FRACTION}.log -v /data/REout_${nameR1}_${FRACTION} /data/${R1}"

rm -r "TEMP_${nameR1}_${FRACTION}"
#rm -r "REout_${nameR1}_${FRACTION}/seqclust"

echo INFO: Summarise Cluster Table
python3 `which SummariseRepExClusterOutput.py` REout_${nameR1}_${FRACTION}/SUPERCLUSTER_TABLE.csv REout_${nameR1}_${FRACTION}/CLUSTER_TABLE.csv $CLASS ${nameR1}

echo END

