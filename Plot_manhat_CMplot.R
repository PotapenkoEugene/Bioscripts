if(!require('dplyr')) install.packages('dplyr'); library('dplyr')
if(!require('data.table')) install.packages('data.table'); library('data.table')
source("https://raw.githubusercontent.com/YinLiLin/CMplot/master/R/CMplot.r")

args = commandArgs(trailingOnly=TRUE)
################################
GWAS1 = args[1] # LFMM gwasUniq custom format
TRAIT = args[2]
SORTED = args[3] # T or F, if FALSE it will be sorted by chr
if(length(args) == 4){
 pval_by_top = args[4]
}else{
 pval_by_top = NULL 
}
################################


# Prepare DFs

message('INFO: PREPARING GWAS1 DATA FRAME')
lfmm.res = fread(GWAS1, sep = '\t', header = T) %>%
	setNames(c('SNP', 'Chromosome', 'Position', TRAIT))

if(is.null(pval_by_top)){
	pval.threshold = 0.05 / nrow(lfmm.res)
}else{
	pval.threshold = lfmm.res[[TRAIT]] %>% head(pval_by_top) %>% max
}

if(SORTED == 'F'){
	lfmm.res <-
		lfmm.res %>%
		dplyr::arrange(Chromosome)
}

# Plot
message('INFO: PLOTTING')
CMplot(lfmm.res  %>% as.data.frame, # return some error to data.table 
       plot.type="m", LOG10=TRUE, ylim=NULL,
       threshold= pval.threshold,
       threshold.lty=2,
       threshold.lwd=1, 
       threshold.col="black", 
       amplify=T,
       bin.size=1e6,
        chr.den.col=c("darkgreen", "yellow", "red"),
       signal.col = 'red',
       signal.cex = 0.5,
       cex = 0.25,
       
       file.name = paste0('CMplot_', TRAIT),
       file="png",
       dpi=1200,
       file.output=TRUE,
       verbose=TRUE,
       width=10,height=6)

