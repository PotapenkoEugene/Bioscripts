if(!require('dplyr')) install.packages('dplyr'); library('dplyr')
if(!require('data.table')) install.packages('data.table'); library('data.table')
source("https://raw.githubusercontent.com/YinLiLin/CMplot/master/R/CMplot.r")

args = commandArgs(trailingOnly=TRUE)
################################
GWAS1 = args[1] # LFMM gwasUniq custom format
GWAS2 = args[2] # EMMAX gwasUniq custom format
TRAIT = args[3]
SORTED = args[4] # T or F, if FALSE it will be sorted by script
if(length(args) == 5){
	CUSTOM_SNP = fread(args[5], header = F)$V1 # should be list without header 
}else(CUSTOM_SNP = NULL)
################################


# Prepare DFs

message('INFO: PREPARING GWAS1 DATA FRAME')
lfmm.res = fread(GWAS1, sep = '\t', header = T) %>%
	setNames(c('SNP', 'Chromosome', 'Position', 'LFMM'))

message('INFO: PREPARING GWAS2 DATA FRAME')
emmax.res = fread(GWAS2, sep = '\t', header = T)

lfmm.res <-
	lfmm.res %>%
		left_join(emmax.res %>% dplyr::select(SNP, pvalue), by = 'SNP') %>%
		dplyr::rename(EMMAX = pvalue)

if(SORTED == 'F'){
	lfmm.res <-
		lfmm.res %>%
		dplyr::arrange(Chromosome)
}

if(is.null(CUSTOM_SNP)){
	pval.threshold = 0.05 / nrow(lfmm.res)

	# Plot
	message('INFO: PLOTTING WITH PVALUE THRESHOLD')
	CMplot(lfmm.res  %>% as.data.frame, # return some error to data.table 
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
	       file="png",
	       dpi=1200,
	       file.output=TRUE,
	       verbose=TRUE,
	       width=10,height=10)
 }else{

	 # Plot
        message('INFO: PLOTTING WITH CUSTOM SNP HIGHLIGHTER')
        CMplot(lfmm.res  %>% as.data.frame, # return some error to data.table
               type="p",
               plot.type="c",
               r=0.4,
               col=c("dodgerblue4", "deepskyblue"),
               cex = 0.2,
               signal.cex = 0.4,

               #threshold= pval.threshold,
		highlight = CUSTOM_SNP,
	       	highlight.cex = 0.5,
		highlight.col = 'red',


               cir.chr.h=1.5,
               amplify=T,
               threshold.lty=1,
               threshold.col="black",
               signal.line=1,
               signal.col="red",
               chr.den.col=c("darkgreen","yellow","red"),
               bin.size=1e6,
               outward=FALSE,
               file.name = paste0('CMplot_CircularDouble_EMMAXandLFMM_customSNP_', TRAIT, '.png'),
	       file="png",
               dpi=1200,
               file.output=TRUE,
               verbose=TRUE,
               width=10,height=10)
}

