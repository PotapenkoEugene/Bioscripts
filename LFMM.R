
library(LEA)
library(dplyr)
library(data.table)
library(WGCNA)
args = commandArgs(trailingOnly=TRUE)

#################################
LFMM_LD_imp = args[1]
LFMM_imp = args[2]
PREDICTORS = args[3]
Kbest = args[4] %>% as.numeric # latent factor number
OUTPREFIX = args[5]
#CPU = args[6] # no needed
#################################

message('INFO: READ LFMM_LD')
lfmm_ld_imp <- 
    fread(LFMM_LD_imp, sep = ' ', header = F)
message(lfmm_ld_imp %>% str)

message('INFO: READ PREDICTORS')
predictors <-
	read.table(PREDICTORS, sep = '\t', header = T)
message(predictors %>% str)


message('INFO: TRAIN LFMM MODEL ON LD DATASET')
# Build model
lfmm.model <-
    lfmm2(lfmm_ld_imp,
          env = predictors,
          K = Kbest)
message(lfmm.model %>% str)

# Save model
#saveRDS(lfmm.model, paste0(OUTPREFIX, '.Rds'))

message('INFO: READ LFMM')
# Make pvalues
lfmm_imp <-
	fread(LFMM_imp, sep = ' ', header = F)
message(lfmm_imp %>% str)

message('INFO: EXTRACT PVALUES FROM THE MODEL')
lfmm.res <-
      lfmm2.test(lfmm.model,
                 input = lfmm_imp,
                 env = predictors)
message(lfmm.res %>% str)

message('INFO: SAVE PVALUES')
if(ncol(lfmm.res$pvalues) != ncol(predictors)){ # For more than one trait it needed to be transposed
	lfmm.res$pvalues %>%
	transposeBigData %>%
	fwrite(paste0(OUTPREFIX, '.pvalues.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)
		 } else{
		lfmm.res$pvalues %>%
        	fwrite(paste0(OUTPREFIX, '.pvalues.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)
}
message('INFO: FINISH')


