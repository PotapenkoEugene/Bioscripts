
library(data.table)
library(dplyr)
library(parallel)
library(qvalue)
############
args <- commandArgs(trailingOnly = TRUE)
PVALS = args[1] # tsv table of pvals from association analysis tool
SNPs = args[2] # snp table (from 1 to 9 first vcf columns with corresponding colnames
	data = cbind(fread(SNPs, sep = ' ', header = T),
		     fread(PVALS, sep = '\t', header = T))
OUTSUFFIX = args[3]
threshold = args[4] # FDR or BC 
############
if(threshold == 'BC'){pval.threshold = rep(0.05 / nrow(data), ncol(data) - 9)} # the same for each trait
if(threshold == 'FDR'){pval.threshold = sapply(data[,10:ncol(data)], function(col) col[qvalue(col)$qvalues < 0.05] %>% max )} # different for each trait
traits = colnames(data[,10:ncol(data)])
names(pval.threshold) = traits

message('INFO: EXTRACT POSITION OF SIGNIFICANT OUTLIER SNPs')
outliers.list <-
  mclapply(traits, function(trait) {

    data[data[[trait]] < pval.threshold[trait],] %>%
	    dplyr::select(CHROM, POS, !!trait) %>%
	    dplyr::rename(pval = !!trait) %>%
	    dplyr::arrange(pval)

  }, mc.cores = ncol(data) - 9) %>%
  setNames(traits)

message('INFO: SAVE TABLES')
lapply(traits, function(trait){

	       outliers.list[[trait]] %>%
		       fwrite(paste0(OUTSUFFIX, '_', trait, '.tsv'), sep = '\t', row.names = F, col.names = T, quote = F)

  })





