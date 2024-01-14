#!/bin/bash
#########################
VCF=$1 ; VCF_name=$(basename $(basename $VCF .vcf.gz) .vcf) # in VCF or VCFGZ format
winsize=$2 #100
stepsize=$3 #20
r2threshold=$4 #0.1
#########################

# Calculate LD
plink --vcf $VCF \
--const-fid \
--allow-extra-chr \
--indep-pairwise $winsize $stepsize $r2threshold \
--out ${VCF_name}.LD${r2threshold} \
--set-missing-var-ids @:#

# Make LD prunned VCF
plink --vcf $VCF \
--const-fid \
--allow-extra-chr \
--set-missing-var-ids @:# \
--extract ${VCF_name}.LD${r2threshold}.prune.in \
--recode vcf \
--out ${VCF_name}.LD${r2threshold}

VCF_LD=${VCF_name}.LD${r2threshold}.vcf

# Edit OUT vcf - remove FAMID
sed -i 's/\t0_/\t/g' $VCF_LD
