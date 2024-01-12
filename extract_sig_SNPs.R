
library(data.table)
library(dplyr)
library(parallel)

############
args <- commandArgs(trailingOnly = TRUE)
PVALS = args[1] # tsv table of pvals from association analysis tool
SNPs = args[2] # snp table (from 1 to 9 first vcf columns with corresponding colnames)
									data = cbind(fread(SNPs, sep = '\t', header = T),
									             fread(PVALS, sep = '\t', header = T))
OUTSUFFIX = args[3]
pval.threshold = ifelse(length(args) == 4,  # write threshold 
			args[4] %>% as.numeric, 
			0.05 / nrow(data)) # default
############
traits = colnames(data[,10:ncol(data)])

message('INFO: EXTRACT POSITION OF SIGNIFICANT OUTLIER SNPs')
outliers.list <-
 data[,10:ncol(data)] %>%
  mclapply(function(col) {

    data[col < pval.threshold,] %>%
	    dplyr::select(CHROM, POS)

  }, mc.cores = ncol(data) - 9) %>%
  setNames(traits)

message('INFO: SAVE TABLES')
lapply(traits, function(trait){

	       outliers.list[[trait]] %>%
		       fwrite(paste0(OUTSUFFIX, '_', trait, '.tsv'), sep = '\t', row.names = F, col.names = T, quote = F)

  })





