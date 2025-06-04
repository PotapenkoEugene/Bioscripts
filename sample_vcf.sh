#!/bin/bash

VCF=$1
N_SNPS=$2
SEED=42

# Set number of SNPs to sample
SAMPLING_RATE=$(echo "scale=10; $N_SNPS/$(bcftools view -H $VCF | wc -l)" | bc)

bcftools view $VCF | \
 awk -v seed=$SEED -v rate=$SAMPLING_RATE 'BEGIN{srand(seed)} /^#/{print;next} {if(rand() <= rate){print}}' | \
 bcftools view -o "$(basename $VCF .vcf)_sampled${N_SNPS}.vcf"
