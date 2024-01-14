library(LEA)
library(dplyr)
library(data.table)
library(ggplot2)
args = commandArgs(trailingOnly=TRUE)
####################
GENO=args[1]
K_START=args[2] %>% as.numeric
K_END=args[3] %>% as.numeric
REPEAT=args[2] %>% as.numeric
CPU=args[3] %>% as.numeric
####################

snmf(GENO,
     CPU = CPU,
     K = K_START:K_END,
     entropy = TRUE,
     repetitions = REPEAT,
     ploidy = 2,
     I = 10000,
     project = 'new')

