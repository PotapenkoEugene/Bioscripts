library(LEA)

args = commandArgs(trailingOnly=TRUE)
VCF=args[1] # VCF filename
FORCE = ifelse(length(args) == 2, args[2], F) #  T or TRUE

vcf2lfmm(VCF, force = as.logical(FORCE))
