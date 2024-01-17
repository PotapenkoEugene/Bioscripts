
args = commandArgs(trailingOnly=TRUE)
LFMM_imp = args[1]
VCF = args[2]
BLOCKSIZE = as.numeric(args[3])
##########################

library(dplyr)
library(data.table)
library(WGCNA)
# Convert  LFMM_imp file to VCF_imp, !! implementation only for full homozygotes !!

# Transform lfmm imputed file into vcf file (WORKAROUND)
geno_imp <-
	fread(LFMM_imp) %>%
	transposeBigData(blocksize = BLOCKSIZE)

gt <- ifelse(geno_imp == 0, '0/0', '1/1')

colnames(gt) <- fread(cmd = paste("grep -A1 -m1 CHROM",
                                      VCF,
                                      "| cut -f10- ")) %>% colnames
snps <- fread(cmd = paste("grep -v \'^##\'",
			  VCF,
			  "| cut -f1-9 "))

# Check the equal number of dim:
if(!dim(gt)[1] == dim(snps)[1]){ print('ERROR') } 

# Merge snps info and GT
vcf.restored <- cbind(snps, gt)
# Save restored VCF file

# Copy meta header
LFMM_imp_vcf = gsub('.lfmm', '.vcf', LFMM_imp)
system(paste("head -1000", VCF,
	     "| grep \'^##\' >", LFMM_imp_vcf))
fwrite(vcf.restored,
       LFMM_imp_vcf,
       append = T,
       col.names = T, row.names = F, sep = '\t', quote = F)
