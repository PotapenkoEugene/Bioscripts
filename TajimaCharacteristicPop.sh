library(ggplot2)
library(pegas)
library(vcfR)

args <- commandArgs(trailingOnly = TRUE)
VCF=args[1]      # path to VCF input file
POP=args[2]     # Prefix

vcf <- read.vcfR(VCF)
vcf.bin <- vcfR2DNAbin(vcf)
tajima <- tajima.test(vcf.bin)
out = paste0(POP, '\t', tajima$D, '\t', tajima$Pval.normal, '\t', tajim$Pval.beta)
write(out, stdout())

