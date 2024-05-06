library(data.table)
library(dplyr)
library(tidyverse)
library(ggplot2) 
library(scattermore)
library(parallel)
library(hudson)
args = commandArgs(trailingOnly=TRUE)

###################################
GWAS1 = args[1] # should be pval sorted with columns SNP, CHR, POS, pvalue
GWAS2 = args[2]
GWAS3 = args[3] # additional for overlap
N = args[4] %>% as.numeric # How many SNPs take for overlap
OUT = args[5] # out filename
###################################

gmirror <- function(top, bottom, tline, bline, chroms = c(1:22, "X", "Y"),log10=TRUE,
                    yaxis, opacity=1, annotate_snp, annotate_p, toptitle=NULL,
                    bottomtitle=NULL, highlight_snp, highlight_p, highlighter="red",
                    chrcolor1="#AAAAAA", chrcolor2="#4D4D4D", freey=FALSE,
                    background="variegated", chrblocks=FALSE, file="gmirror",
                    type="png", hgt=7, hgtratio=0.5, wi=12, res=300, POINTSIZE = 10, PIXL1 = 1382, PIXL2 = 691){

  #Sort data
  topn <- names(top)
  bottomn <- names(bottom)
  top$Location <- "Top"
  bottom$Location <- "Bottom"

  # Check file formats
  if(!identical(topn, bottomn)){stop("Please ensure both inputs have the same metadata columns.")}

  d <- as.data.frame(rbind(top, bottom))

  d$POS <- as.numeric(as.character(d$POS))
  d$CHR <- droplevels(factor(d$CHR, levels = as.character(chroms)))
  d <- d[d$CHR %in% chroms, ]
  d_order <- d[order(d$CHR, d$POS), ]
  d_order$pos_index <- seq.int(nrow(d_order))
  d_order_sub <- d_order[, c("SNP", "CHR", "POS", "pvalue", "pos_index")]

  #Set up dataframe with color and position info
  maxRows <- by(d_order_sub, d_order_sub$CHR, function(x) x[which.max(x$pos_index),])
  minRows <- by(d_order_sub, d_order_sub$CHR, function(x) x[which.min(x$pos_index),])
  milimits <- do.call(rbind, minRows)
  malimits <- do.call(rbind, maxRows)
  lims <- merge(milimits, malimits, by="CHR")
  names(lims) <- c("Color", "snpx", "px", "posx", "posmin", "snpy", "py", "posy", "posmax")
  lims$av <- (lims$posmin + lims$posmax)/2
  lims <- lims[order(lims$Color),]
  lims$shademap <- rep(c("shade_ffffff", "shade_ebebeb"), length.out=nrow(lims), each=1)

  #Set up colors
  nchrcolors <- nlevels(factor(lims$Color))

  #Color by CHR
  colnames(d_order)[2] <- "Color"
  newcols <-c(rep(x=c(chrcolor1, chrcolor2), length.out=nchrcolors, each=1), "#FFFFFF", "#EBEBEB")
  names(newcols) <-c(levels(factor(lims$Color)), "shade_ffffff", "shade_ebebeb")

  #Info for y-axis
  if(log10==TRUE){
    d_order$pval <- -log10(d_order$pvalue)
    yaxislab1 <- expression(paste("-log"[10], "(p-value)", sep=""))
    yaxislab2 <- expression(paste("-log"[10], "(p-value)", sep=""))
    if(!missing(tline)) {tredline <- -log10(tline)}
    if(!missing(bline)) {bredline <- -log10(bline)}
  } else {
    d_order$pval <- d_order$pvalue
    yaxislab1 <- yaxis[1]
    yaxislab2 <- yaxis[2]
    if(!missing(tline)) {tredline <- tline}
    if(!missing(bline)) {bredline <- bline}
  }
  yaxismax1 <- ifelse(freey==FALSE, max(d_order$pval[which(d_order$pval< Inf)]), max(d_order$pval[which(d_order$pval< Inf) & d_order$Location=="Top"]))
  yaxismax2 <- ifelse(freey==FALSE, max(d_order$pval[which(d_order$pval< Inf)]), max(d_order$pval[which(d_order$pval< Inf) & d_order$Location=="Bottom"]))
  yaxismin1 <- ifelse(freey==FALSE, 0, min(d_order$pval[d_order$Location=="Top"]))
  yaxismin2 <- ifelse(freey==FALSE, 0, min(d_order$pval[d_order$Location=="Bottom"]))

  #Theme options
  backpanel1 <- ifelse(background=="white", "NULL", "geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = yaxismin1, ymax = Inf, fill=factor(shademap)), alpha = 0.5)" )
  backpanel2 <- ifelse(background=="white", "NULL", "geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = yaxismin2, ymax = Inf, fill=factor(shademap)), alpha = 0.5)" )

  #Start plotting
  #TOP PLOT
  p1 <- ggplot() + eval(parse(text=backpanel1))
  #Add shape info if available
  if("Shape" %in% topn){
    p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$Location=="Top",], aes(x=pos_index, y=pval, color=factor(Color), shape=factor(Shape)), alpha=opacity, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
  } else {
    p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$Location=="Top",], aes(x=pos_index, y=pval, color=factor(Color)), alpha=opacity, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
  }
  p1 <- p1 + scale_x_continuous(breaks=lims$av, labels=lims$Color, expand=c(0,0))
  if(chrblocks==TRUE){
    p1 <- p1 + geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = -Inf, ymax = min(d_order$pval), fill=as.factor(Color)), alpha = 1)
  }
  p1 <- p1 + scale_colour_manual(name = "Color", values = newcols) + scale_fill_manual(name = "Color", values = newcols)
  p1 <- p1 + theme(panel.grid.minor.x = element_blank(), panel.grid.major.x=element_blank(), axis.title.x=element_blank(), legend.position="top", legend.title=element_blank())

  #BOTTOM PLOT
  p2 <- ggplot() + eval(parse(text=backpanel2))
  #Add shape info if available
  if("Shape" %in% bottomn){
    p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$Location=="Bottom",], aes(x=pos_index, y=pval, color=factor(Color), shape=factor(Shape)), alpha=opacity, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
  } else {
    p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$Location=="Bottom",], aes(x=pos_index, y=pval, color=factor(Color)), alpha=opacity, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
  }
  p2 <- p2 + scale_x_continuous(breaks=lims$av, labels=lims$Color, expand=c(0,0))
  if(chrblocks==TRUE){
    p2 <- p2 + geom_rect(data = lims, aes(xmin = posmin-.5, xmax = posmax+.5, ymin = -Inf, ymax = min(d_order$pval), fill=as.factor(Color)), alpha = 1)
  }
  p2 <- p2 + scale_colour_manual(name = "Color", values = newcols) + scale_fill_manual(name = "Color", values = newcols)
  p2 <- p2 + theme(axis.text.x=element_text(angle=90), panel.grid.minor.x = element_blank(), panel.grid.major.x=element_blank(), axis.title.x=element_blank(), legend.position="bottom", legend.title=element_blank())

  #Highlight if given
  if(!missing(highlight_snp)){
    if("Shape" %in% topn){
      p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Top", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
      p1 <- p1 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Top", ], aes(x=pos_index, y=pval), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
    }
    if("Shape" %in% bottomn){
      p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
      p2 <- p2 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$SNP %in% highlight_snp & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
    }
  }
  if(!missing(highlight_p)){
    if("Shape" %in% topn){
      p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$pvalue < highlight_p[1] & d_order$Location=="Top", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
      p1 <- p1 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p1 <- p1 + scattermore::geom_scattermore(data=d_order[d_order$pvalue < highlight_p[1] & d_order$Location=="Top", ], aes(x=pos_index, y=pval), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
    }
    if("Shape" %in% bottomn){
      p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$pvalue < highlight_p[2] & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval, shape=Shape), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
      p2 <- p2 + guides(shape = guide_legend(override.aes = list(colour = "black")))
    } else {
      p2 <- p2 + scattermore::geom_scattermore(data=d_order[d_order$pvalue < highlight_p[2] & d_order$Location=="Bottom", ], aes(x=pos_index, y=pval), colour=highlighter, pointsize=POINTSIZE, pixels=c(PIXL1,PIXL2))
    }
  }
  #Add pvalue threshold line
  if(!missing(tline)){
    for(i in 1:length(tline)){
      p1 <- p1 + geom_hline(yintercept = tredline[i], colour="red")
    }
  }
  if(!missing(bline)){
    for(i in 1:length(bline)){
      p2 <- p2 + geom_hline(yintercept = bredline[i], colour="red")
    }
  }
  #Annotate
  if(!missing(annotate_p)){
    if (!requireNamespace(c("ggrepel"), quietly = TRUE)==TRUE) {
      print("Consider installing 'ggrepel' for improved text annotation")
      p1 <- p1 + geom_text(data=d_order[d_order$pvalue < annotate_p[1] & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + geom_text(data=d_order[d_order$pvalue < annotate_p[2] & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    } else {
      p1 <- p1 + ggrepel::geom_text_repel(data=d_order[d_order$pvalue < annotate_p[1] & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + ggrepel::geom_text_repel(data=d_order[d_order$pvalue < annotate_p[2] & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    }
  }
  if(!missing(annotate_snp)){
    if (!requireNamespace(c("ggrepel"), quietly = TRUE)==TRUE){
      print("Consider installing 'ggrepel' for improved text annotation")
      p1 <- p1 + geom_text(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + geom_text(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    } else {
      p1 <- p1 + ggrepel::geom_text_repel(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Top",], aes(pos_index,pval,label=SNP))
      p2 <- p2 + ggrepel::geom_text_repel(data=d_order[d_order$SNP %in% annotate_snp & d_order$Location=="Bottom",], aes(pos_index,pval,label=SNP))
    }
  }
  #Add title and y axis title
  p1 <- p1 + ylab(yaxislab1)
  p2 <- p2 + ylab(yaxislab2)

  #Format
  if(chrblocks==TRUE){
    if(freey==TRUE){
      print("Sorry, drawing chrblocks with freey=TRUE is currently unsupported and will be ignored.")
    } else {
      p1 <- p1+theme(axis.text.x = element_text(vjust=1),axis.ticks.x = element_blank())+ylim(c(yaxismin1,yaxismax1))
      p2 <- p2+scale_y_reverse(limits=c(yaxismax2, yaxismin2)) + theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())
    }
  } else {
    p1 <- p1+theme(axis.text.x = element_text(vjust=1),axis.ticks.x = element_blank())+ scale_y_continuous(limits=c(yaxismin1, yaxismax1),expand=expansion(mult=c(0,0.1)))
    p2 <- p2+scale_y_reverse(limits=c(yaxismax2,yaxismin2), expand=expansion(mult=c(0.1,0))) + theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())
  }

  if(background=="white"){
    p1 <- p1 + theme(panel.background = element_rect(fill="white"))
    p2 <- p2 + theme(panel.background = element_rect(fill="white"))
  }
  p1 <- p1 + guides(fill="none", color="none")
  p2 <- p2 + guides(fill="none", color="none")
  #Save
  print(paste0("Saving plot to ", file, ".", type))
  p <- grid.arrange(arrangeGrob(p1, top=toptitle), arrangeGrob(p2, bottom=bottomtitle), padding=0, heights=c(hgtratio,1-hgtratio))
  ggsave(p, filename=paste0(file, ".", type), dpi=res, units="in", height=hgt, width=wi)
  return(p)
}

################## MAIN ####################
df1 = fread(GWAS1, sep = '\t', header = T) %>% dplyr::mutate(CHR = gsub('chr|H', '', CHR) %>% as.factor)
df2 = fread(GWAS2, sep = '\t', header = T) %>% dplyr::mutate(CHR = gsub('chr|H', '', CHR) %>% as.factor)
df3 = fread(GWAS3, sep = '\t', header = T) %>% dplyr::mutate(CHR = gsub('chr|H', '', CHR) %>% as.factor)

df1_head = df1 %>% head(N)
df2_head = df2 %>% head(N)
df3_head = df3 %>% head(N)

highlight_snp = intersect(df1_head$SNP, df2_head$SNP) %>% intersect(df3_head$SNP)

threshold_gwas1 = df1[N,]$pvalue
threshold_gwas2 = df2[N,]$pvalue
threshold_gwas3 = df3[N,]$pvalue

# Data check
message(df1 %>% str)
message(df2 %>% str)
message(threshold_gwas1 %>% str)
message(threshold_gwas2 %>% str)
message(highlight_snp %>% str)

gmirror(top=df1, 
          bottom=df2, 
          tline=threshold_gwas1, 
          bline=threshold_gwas2, 
	  toptitle=GWAS1, 
	  bottomtitle=GWAS2, 
	  # highlight_p = c(threshold_emmax,
	  #                 threshold_lfmm),
	  highlight_snp = highlight_snp,
	  highlighter="red",
	  PIXL1 = 5000, PIXL2 = 1000, 
	  file = OUT
 )
