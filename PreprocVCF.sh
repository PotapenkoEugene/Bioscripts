#!/bin/bash

# INPUT
VCFGZ=$1 ; name=$(basename $VCFGZ .vcf.gz)
SAMPLES=$2
LD=$3
MAF=$4

# OUTPUT
SUBSET="FILTRED/${name}.SS.vcf.gz"
LDMAF="FILTRED/${name}.SS.MAF${MAF}.LD${LD}.vcf.gz"

mkdir FILTRED
# Subset samples
bcftools view --threads 20 -S $SAMPLES $VCFGZ -Oz -o $SUBSET

# FILTER by LD and MAF
bcftools +prune -l $LD -e'MAF<=0.05' $SUBSET -Oz -o $LDMAF
