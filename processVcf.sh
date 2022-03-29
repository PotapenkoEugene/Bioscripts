#!/bin/bash


################################
VCFGZ=$1
LD=$2 # 0.5
WINSIZE=$3 # 100 (kb)
STEPSIZE=$4 # 10 (kb)
MAF=$5 # 0.01
NE=20000000 # effective population size
MEM=$6
################################

NAME=$(basename $VCFGZ .vcf.gz)
JAVA_TOOL_OPTIONS="-Xmx${MEM}g"

conda activate beagle
# impute vcf with beagle 5.2
beagle gt=${VCFGZ} out=${NAME}.beagle ne=${NE}
beagle gt=${NAME}.beagle.vcf.gz out=${NAME}.beagle2 ne=${NE}

VCFGZIMP=${NAME}.beagle2.vcf.gz
NAMEIMP=$(basename ${VCFGZIMP} .vcf.gz)
#prune vcf
plink --vcf ${VCFGZIMP} --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise ${WINSIZE} ${STEPSIZE} ${LD} --out ${NAMEIMP}.LD${LD}
sed 's/:/ /g' ${NAMEIMP}.LD${LD}.prune.in > ${NAMEIMP}.LD${LD}.list
vcftools --gzvcf ${VCFGZIMP} --positions ${NAMEIMP}.LD${LD}.list --maf ${MAF} --recode --stdout > ${NAMEIMP}.LD${LD}.vcf
