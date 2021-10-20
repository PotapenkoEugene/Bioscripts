#!/bin/bash

#########################################################################################
# Script must be run in SnpEff dir 
# SnpEff download https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
#########################################################################################
# Firstly download db 
# ClinVAR https://ftp.ncbi.nlm.nih.gov/pub/clinvar/ # need clinvar.vcf.gz + md5 + tbi
# dbSNFP https://pcingola.github.io/SnpEff/ss_dbnsfp/ # ~30Gb !!!
# GWAS https://www.ebi.ac.uk/gwas/docs/file-downloads # associations file
# SnpEff downloaded automaticaly
#########################################################################################

##############
GENOMENAME=$1
VCF=$2 # not gzip
CLINVAR=$3
GWAS=$4
SNFP=$5
RAM=$6 # in Gb
##############

vcfname=$(basename $VCF .vcf)
mkdir RESULT
# SnpEff canonical transcripts annotation
java -Xmx${RAM}g -jar snpEff.jar -v -canon $GENOMENAME $VCF > RESULT/${name}_Canon.vcf
# ClinVar annotation
java -Xmx${RAM}g -jar SnpSift.jar annotate -v $CLINVAR RESULT/${name}_Canon.vcf > RESULT/${name}_Canon_ClinVar.vcf
# GWAS annotation
java -Xmx${RAM}g -jar SnpSift.jar gwasCat -db $GWAS -v RESULT/${name}_Canon_ClinVar.vcf > RESULT/${name}_Canon_ClinVar_GWAS.vcf
# dbSNPF
java -Xmx${RAM}g -jar SnpSift.jar dbnsfp -v -db $SNFP RESULT/${name}_Canon_ClinVar_GWAS.vcf > RESULT/${name}_Canon_ClinVar_GWAS_dbSNPFP.vcf
# Filter out SNPs that not change the protein structure/functions
java -Xmx${RAM}g -jar SnpSift.jar filter -v " ( (ANN[0].IMPACT has 'HIGH') | (ANN[0].IMPACT has 'MODERATE') | (exists CLNSIGINCL) | (exists GWASCAT_TRAIT) | (exists dbNSFP_MetaSVM_pred) | (exists dbNSFP_phastCons100way_vertebrate) | ( exists dbNSFP_ExAC_NFE_AF) | ( exists dbNSFP_Interpro_domain) ) " RESULT/${name}_Canon_ClinVar_GWAS_dbSNPFP.vcf > RESULT/${name}_Canon_ClinVar_GWAS_dbSNPFP.filtred.vcf


