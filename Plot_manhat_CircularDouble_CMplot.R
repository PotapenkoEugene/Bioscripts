if(!require('dplyr')) install.packages('dplyr'); library('dplyr')
if(!require('data.table')) install.packages('data.table'); library('data.table')
source("https://raw.githubusercontent.com/YinLiLin/CMplot/master/R/CMplot.r")

args = commandArgs(trailingOnly=TRUE)
################################
SNPs = args[1] # space delimeter
GWAS1 = args[2] # tsv 
GWAS2 = args[3] # tsv
TRAIT = args[4]
################################


# Prepare DFs
message('INFO: PREPARING SNPs DATA FRAME')
snps = fread(SNPs, header = T) %>% dplyr::select(CHROM, POS) %>%
  dplyr::mutate(SNP = paste0('V', 1:n())) %>%
  dplyr::select(SNP, everything()) %>%
  setNames(c('SNP', 'Chromosome', 'Position'))

message('INFO: PREPARING GWAS1 DATA FRAME')
lfmm.res = fread(GWAS1, sep = '\t', header = T) %>%
  setNames(gsub('bio', 'bio_', colnames(.)))

message('INFO: PREPARING GWAS2 DATA FRAME')
emmax.res = fread(GWAS2, sep = '\t', header = T)

pval.threshold = 0.05 / nrow(snps)

# Plot
message('INFO: PLOTTING')
CMplot(cbind(snps,
             LFMM = lfmm.res[[TRAIT]],
             EMMAX = emmax.res[[TRAIT]]) %>% as.data.frame, # return some error to data.table 
       type="p",
       plot.type="c",
       r=0.4,
       col=c("dodgerblue4", "deepskyblue"),
       cex = 0.2,
       signal.cex = 0.4,

       threshold= pval.threshold,
       cir.chr.h=1.5,
       amplify=T,
       threshold.lty=1,
       threshold.col="black",
       signal.line=1,
       signal.col="red",
       chr.den.col=c("darkgreen","yellow","red"),
       bin.size=1e6,
       outward=FALSE,
       file.name = paste0('CMplot_CircularDouble_EMMAXandLFMM_', TRAIT, '.png'),
       file="jpg",
       dpi=300,
       file.output=TRUE,
       verbose=TRUE,
       width=10,height=10)
