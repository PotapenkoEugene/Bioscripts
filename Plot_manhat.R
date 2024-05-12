if(!require('ggrepel')) install.packages('ggrepel'); library(ggrepel)
if(!require('ggplot2')) install.packages('ggplot2'); library(ggplot2)
if(!require('scattermore')) install.packages('scattermore'); library(scattermore)
if(!require('data.table')) install.packages('data.table'); library(data.table)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('ggh4x')) install.packages('ggh4x'); library(ggh4x)
if(!require('qvalue')) install.packages('qvalue'); library(qvalue)
if(!require('magrittr')) install.packages('magrittr'); library(magrittr)

args = commandArgs(trailingOnly=TRUE)
######################
gwas_df=fread(args[1], sep = '\t', header = T) 
pval_colname=args[2]
snps_df=fread(args[3], sep = ' ', header = T) %>% dplyr::select(CHROM, POS)
threshold=args[4] # FDR or BC
OUTSUFFIX=args[5]
######################

if(threshold == 'BC') {pval.threshold = 0.05 / nrow(snps_df)}
if(threshold == 'FDR') {qval.threshold = 0.05}

FUN_manhat <- function(pvalue, #vector
                       snps, # snps full
                       
                       sig = NULL, # specified highlighted SNPs instead of pval.threshold
                       qval.threshold = 0.05,
                       pval.threshold = NULL,
                       
                       highlight.lines = NULL, # list of vectors c(chr, pos)
                       linewidth = 0.01,
                       line.alpha = 0.5,
                       pointsize = 6,
                       
                       labels = NULL # should be with 3 column: CHROM POS gene
                       ){
    
  df <- 
      pvalue %>% 
      as.data.frame %>%
      setNames('pval') %>%
      cbind(snps, .) %>%
      dplyr::mutate(qvalue = qvalue(pval)$qvalues)

  
  if(is.null(pval.threshold)){
    pval.threshold <- 
      df %>% dplyr::filter(qvalue < qval.threshold) %>% .$pval %>% max
  }
  
  if(is.null(sig)){
    df %<>%
      dplyr::mutate(sig = pval < pval.threshold)
  } else {
    df %<>%
      dplyr::mutate(sig = paste0('V', 1:nrow(snps)) %in% sig)
  }
  
  # INFO
  message('INFO: Printed df structure:')
  print(df %>% str)

  # Labels 
  if(!is.null(labels)){
    df %<>%
      left_join(labels, by = c('CHROM', 'POS'))
	
    gPlot <- df %>% ggplot(aes(x = POS, y = -log10(pval), color = sig, label = gene))	
  } else {
    gPlot <- df %>% ggplot(aes(x = POS, y = -log10(pval), color = sig))
  }
  
  # Continue plotting
  gPlot <-
    gPlot +
          facet_wrap2(vars(CHROM), nrow=1) + #, scales = "free_x", switch = "x")  +
          geom_scattermore(pointsize = pointsize) +
          geom_hline(yintercept=-log10(pval.threshold), linetype="dashed", color = "black") +
          labs(x = 'Chromosome',
               y = '-log10(p-value)') +
          scale_color_manual(values=c('grey', 'red')) +
          theme(
                axis.text.x = element_blank(),
                axis.title = element_text(size = 15),
                axis.ticks.x = element_blank(),
                legend.position = 'none'							
              )													
  										message("INFO: check gPlot object properly created")
	  print(gPlot %>% str)
  # Lines
  if(!is.null(highlight.lines)){ 
    
    for(i in 1:length(highlight.lines)){
                                                                                                message(paste0('INFO: DRAW VLINE',i))
      chr = highlight.lines[[i]][1]
      pos = highlight.lines[[i]][2] %>% as.numeric
      
      gPlot <-
        gPlot + 
        geom_vline(data = df %>% dplyr::filter(CHROM == !!chr), aes(xintercept = !!pos), 
                   linetype = "longdash", 
                   linewidth = linewidth,
                   alpha = line.alpha)
      }
  }
  											   
  # Labels
  if(!is.null(labels)){	
    												message('INFO: LABELING')
    gPlot <-
      gPlot +
      geom_text_repel(color = 'black', max.overlaps = 9999, size = 2.5, alpha = 0.5)
  }
  
												message('INFO: SUCCESSFULLY PLOTTED')  
  return(gPlot)
}

if(threshold == 'BC'){
gPic <-
	FUN_manhat(gwas_df[[pval_colname]], 
	   snps_df, 
	   pval.threshold = pval.threshold
	)
} else {
gPic <-
        FUN_manhat(gwas_df[[pval_colname]], 
           snps_df, 
           qval.threshold = qval.threshold
	)
}
												message('INFO: LOOK ON RESULT GGPLOT OBJECT')
print(gPic %>% str)
										message(paste0('INFO: SAVE PLOT INTO: ', OUTSUFFIX, '.png'))

#saveRDS(gPic, 'test.Rds') #TEMP

ggsave(filename = paste0(OUTSUFFIX, '.png'), 
      plot = gPic)
