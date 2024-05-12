if(!require('data.table')) install.packages('data.table'); library(data.table)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('qvalue')) install.packages('qvalue'); library(qvalue)
args = commandArgs(trailingOnly=TRUE)
######################
GWAS=fread(args[1], sep = '\t', header = T)
pval_colname=args[2]
VCFSNP=fread(args[3], sep = ' ', header = T)
OUT=args[4]
######################

df = cbind(SNP = paste0(VCFSNP$CHROM, ':', VCFSNP$POS),
      CHR = VCFSNP$CHROM,
      POS = VCFSNP$POS,
      pvalue = GWAS[[pval_colname]])

print(df %>% str)

df %>%
	dplyr::arrange(pvalue) %>%
	fwrite(OUT, sep = '\t', row.names=F, col.names=F, quote = F)
