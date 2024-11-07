#!/bin/bash
#########################
VCF=$1 ; VCF_name=$(basename $(basename $VCF .vcf.gz) .vcf) # in VCF or VCFGZ format
maf=$2
miss=$3
winsize=$4 #100
stepsize=$5 #20
r2threshold=$6 #0.1
#########################
VCF_f=${VCF_name}_MAF${maf}_MISS${miss}.vcf
VCF_f_name=$(basename $VCF_f .vcf)

# Filter MAF MISS
plink --vcf $VCF \
--const-fid \
--allow-extra-chr \
--set-missing-var-ids @:# \
--maf $2  \
--geno $3 \
--recode vcf \
--out ${VCF_f_name}

# Calculate LD
plink --vcf $VCF_f \
--const-fid \
--allow-extra-chr \
--indep-pairwise $winsize $stepsize $r2threshold \
--out ${VCF_f_name}.LD${r2threshold} \
--set-missing-var-ids @:#

# Make PCA
plink --vcf $VCF_f \
--const-fid \
--allow-extra-chr \
--set-missing-var-ids @:# \
--extract ${VCF_f_name}.LD${r2threshold}.prune.in \
--make-bed \
--pca \
--recode vcf \
--out ${VCF_f_name}.LD${r2threshold}

VCF_f_LD=${VCF_f_name}.LD${r2threshold}.vcf

# Edit OUT vcf - remove FAMID
sed -i '/^#/s/\t0_/\t/g' $VCF_f
sed -i '/^#/s/\t0_/\t/g' $VCF_f_LD
