#!/bin/bash


#############
FA=$1
CLASS=$2
THREADS=$3
#############

echo INFO: Start RepeatExplorer2 analysis

mkdir -p "TEMP_${FA}" # TEMP dir in cur dir

source ${CONDA_PREFIX}/etc/profile.d/conda.sh
conda activate singularity
SINGULARITY_TMPDIR=/mnt/data/eugene/SINGULARITY/tmp SINGULARITY_CACHEDIR=/mnt/data/eugene/SINGULARITY/cache singularity exec -W . --bind ${PWD}:/data/ /mnt/data/eugene/Tools/repex_tarean_latest.sif /bin/bash -c "export TEMP=/data/TEMP_${FA}; seqclust -tax VIRIDIPLANTAE3.0 -c ${THREADS} -p -C -l /data/REout_${FA}.log -v /data/REout_${FA} /data/${FA}"

rm -r "TEMP_${FA}"
rm -r "REout_${FA}/seqclust"

echo INFO: Summarise Cluster Table
python3 `which SummariseRepExClusterOutput.py` REout_${FA}/SUPERCLUSTER_TABLE.csv REout_${FA}/CLUSTER_TABLE.csv $CLASS ${FA}

echo END
