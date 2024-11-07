if(!require('ggrepel')) install.packages('ggrepel'); library(ggrepel)
if(!require('ggplot2')) install.packages('ggplot2'); library(ggplot2)
if(!require('scattermore')) install.packages('scattermore'); library(scattermore)
if(!require('data.table')) install.packages('data.table'); library(data.table)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('ggh4x')) install.packages('ggh4x'); library(ggh4x)
if(!require('qvalue')) install.packages('qvalue'); library(qvalue)
if(!require('magrittr')) install.packages('magrittr'); library(magrittr)
if(!require('stringr')) install.packages('stringr'); library(stringr)
if(!require('topr')) devtools::install_github("totajuliusd/topr"); library(topr)

args = commandArgs(trailingOnly=TRUE)
######################
gwasUniq_df1=fread(args[1], sep = '\t', header = T) %>% 
	dplyr::rename(CHROM = CHR, P = pvalue) %>% 
	dplyr::mutate(CHROM = gsub('chr|H', '', CHROM))
gwasUniq_df2=fread(args[2], sep = '\t', header = T) %>% 
	dplyr::rename(CHROM = CHR, P = pvalue) %>% 
	dplyr::mutate(CHROM = gsub('chr|H', '', CHROM))
GENE_ANNOTATION=args[3] # specifically prepared file chrom,gene_start,gene_end,ID,GENE,biotype,exon_chromstart,exon_chromend (exons coordinates separated by comma)
REGION=args[4] # chr:start-end *chr should be numeric
EXPAND=args[5] %>% as.numeric # on what number expand provided region
OUTNAME=args[6] # output prefix
if(length(args) > 6){
	KEEP_GENES=args[7] # comma separated list of gene symbols (descriptions) to keep on the region plot OR could be equal NA to not show any gene names, if argument is not specified all gene names will be shown
}else{KEEP_GENES = NULL}
######################
# Load annotation

# Expand region
chr = REGION %>% str_extract('([0-9]):', group = 1)
start = REGION %>% str_extract('[0-9]:([0-9]+)-[0-9]+', group = 1) %>% as.numeric
end = REGION %>% str_extract('[0-9]:[0-9]+-([0-9]+)', group = 1) %>% as.numeric
REGION = paste0(chr, ':', start - EXPAND, '-', end + EXPAND)

gene_annotation <- read.delim(GENE_ANNOTATION, sep="\t",header=T)
gene_annotation$biotype = 'protein_coding'

if(KEEP_GENES == 'NA'){ 
	gene_annotation$gene_symbol = NA
}else{
	keep_genes = KEEP_GENES %>% str_split(',') %>% unlist
	gene_annotation %<>%
		dplyr::mutate(gene_symbol = ifelse(gene_symbol %in% keep_genes, gene_symbol, NA))
}
# Plot
png(paste0(OUTNAME, '.png'), width = 5000, height = 2500, res = 300)

regionplot(list(GWAS1 = gwasUniq_df1,
                GWAS2 = gwasUniq_df2),
           build=gene_annotation,
           region = REGION,
           sign_thresh = 1.8e-09,
           max.overlaps = 999,
           show_gene_names = T,
           show_genes = T,

           unit_overview = 3,
           unit_gene = 4,

           show_gene_legend = F,
           gene_label_size = 6,
           # nudge_y = 1,
           # nudge_x = 20,

           axis_text_size = 16,
           axis_title_size = 18,
           title_text_size = 18,
           legend_position = 'none',
           scale = 1,
           segment.size = 3,
           legend_labels = c('GWAS1', 'GWAS2'),
           sign_thresh_label_size = 0)

dev.off()
