
library(LEA)
library(dplyr)
args = commandArgs(trailingOnly=TRUE)
######################
SNMF = args[1] # path to snmfProject
LFMM = args[2] # path to LFMM with missing values
Kbest = args[3] %>% as.numeric

######################
LFMM_imp = paste0(gsub('.lfmm', '', LFMM), '_K', Kbest, '_imputed.lfmm')

project = load.snmfProject(SNMF)
# Select the run with the lowest cross-entropy value
Entropy.best = which.min(cross.entropy(project, K = Kbest))
# Impute the missing genotypes
impute(project, LFMM, method = 'mode', K = Kbest, run = Entropy.best)
# Rename
file.rename(from = paste0(LFMM, '_imputed.lfmm'), to = LFMM_imp)

