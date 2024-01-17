
library(LEA)
library(dplyr)
library(data.table)
library(WGCNA)
args = commandArgs(trailingOnly=TRUE)
#################################
LFMM_imp = args[1]
PREDICTORS = args[2]
Kbest = args[3] %>% as.numeric # latent factor number
OUTPREFIX = args[4]
#CPU = args[6] # no needed
#################################
message('INFO: READ LFMM')
# Make pvalues
lfmm_imp <-
        fread(LFMM_imp, sep = ' ', header = F)
print(lfmm_imp %>% str)

message('INFO: READ PREDICTORS')
predictors <-
	read.table(PREDICTORS, sep = '\t', header = T)
print(predictors %>% str)

message('INFO: TRAIN LFMM MODEL')
# Build model
lfmm.model <-
    lfmm2(lfmm_imp,
          env = predictors,
          K = Kbest)
print(lfmm.model %>% str)

message('INFO: EXTRACT PVALUES FROM THE MODEL')
lfmm.res <-
      lfmm2.test(lfmm.model,
                 input = lfmm_imp,
                 env = predictors)
print(lfmm.res %>% str)

message('INFO: SAVE PVALUES')
if(ncol(lfmm.res$pvalues) != ncol(predictors)){ # For more than one trait it needed to be transposed
	lfmm.res$pvalues %>%
	transposeBigData %>%
	as.data.table %>%
	fwrite(paste0(OUTPREFIX, '.pvalues.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)
		 } else{
		lfmm.res$pvalues %>%
        	fwrite(paste0(OUTPREFIX, '.pvalues.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)
}

message('INFO: SUCCESSFUL FINISHED')
