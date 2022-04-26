#!/bin/bash


################################
VCFGZ=$1
LD=$2 # 0.5
WINSIZE=$3 # 100 (kb)
STEPSIZE=$4 # 10 (kb)
MAF=$5 # 0.01
NE=20000000 # effective population size
MEM=$6
CPU=$7
source ${CONDA_PREFIX}/etc/profile.d/conda.sh
################################

NAME=$(basename $VCFGZ .vcf.gz)
JAVA_TOOL_OPTIONS="-Xmx${MEM}g"

conda activate beagle
# impute vcf with beagle 5.2
beagle gt=${VCFGZ} out=${NAME}.beagle ne=${NE} nthreads=${CPU}
beagle gt=${NAME}.beagle.vcf out=${NAME}.beagle2 ne=${NE} nthreads=${CPU}

VCFGZIMP=${NAME}.beagle2.vcf
NAMEIMP=$(basename ${VCFGZIMP} .vcf)
#prune vcf
plink --vcf ${VCFGZIMP} --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise ${WINSIZE} ${STEPSIZE} ${LD} --out ${NAMEIMP}.LD${LD}
sed 's/:/ /g' ${NAMEIMP}.LD${LD}.prune.in > ${NAMEIMP}.LD${LD}.list
vcftools --gzvcf ${VCFGZIMP} --positions ${NAMEIMP}.LD${LD}.list --maf ${MAF} --recode --stdout > ${NAMEIMP}.LD${LD}.vcf
