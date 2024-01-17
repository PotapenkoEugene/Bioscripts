

args = commandArgs(trailingOnly=TRUE)
TPED = args[1]
SAMPLES_N = as.numeric(args[2])
#######################################
library(data.table)
library(dplyr)
library(WGCNA)
#######################################

tped <- 
  fread(TPED) %>%
  dplyr::select(-V1, -V2, -V3, -V4)

# Replace 0 to 9 MISSING VALUES
for(i in colnames(tped)) {
  set(tped, which(tped[[i]] == 0), i, 9)
}
# Replace 1 to 0 REF ALLELE
for(i in colnames(tped)) {
  set(tped, which(tped[[i]] == 1), i, 0)
}

# Drop duplicated columns - because we have homozygoutes
mask = 1:(SAMPLES_N * 2) %in% seq(1, SAMPLES_N * 2, 2)
tped = tped[,..mask]

# Transpose 
lfmm = transposeBigData(tped)

lfmm %>%
  fwrite(gsub('.tped', '.lfmm', TPED), col.names = F, row.names = F, quote = F, sep = ' ')
