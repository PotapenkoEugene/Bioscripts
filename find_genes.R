# EXAMPLE: docker run --rm -v `pwd`:/data -u $UID -w /data rstudio_eaa3 Rscript find_genes.R BLINK.MAF005.VanRaden.PC3.OUTLIERS.BC_${trait}.tsv Barley_Morex_V2_gene_annotation_PGSB.all.gff3 250000 GENES/GAPIT_${trait}.genes

if(!require('dplyr')) BiocManager::install('dplyr'); library(dplyr)
if(!require('data.table')) BiocManager::install('data.table'); library(data.table)
if(!require('magrittr')) BiocManager::install('magrittr'); library(magrittr)
if(!require('ttplot')) devtools::install_github("YTLogos/ttplot"); library(ttplot)
if(!require('stringr')) BiocManager::install('stringr'); library(stringr)

args <- commandArgs(trailingOnly = TRUE)
##################
OUTLIERS = read.table(args[1], sep = '\t', head = T) # CHROM POS table
GFF3 = args[2]
DISTANCE = args[3] %>% as.numeric
OUTTABLE = args[4]
##################


FUN_candidate <- function(outliers, GFF3, DISTANCE = 50000){

	message('INFO: TRANSFORM SNP TABLE')
  outliers %<>%
	  dplyr::mutate(SNP = paste0('V', 1:n())) %>%
	  dplyr::select(SNP, everything()) %>%
	  setNames(c('SNP', 'CHR', 'BP')) %>%
	  dplyr::mutate(P = 'sig')
	message('INFO: TRANSFORM GFF3 FILE')
  gff.gene <-
    fread(cmd = paste0('grep mRNA ', GFF3)) %>% # read gff and find in mRNA tags
      dplyr::select(V1,V3,V4,V5,V9) %>%
      setNames(c('chr', 'type', 'start' ,'end' , 'description')) %>%
      dplyr::mutate(gene = stringr::str_extract(description, "(?<=description=)[^;]+")) %>% # Parse to extract GENENAMES
      dplyr::mutate(ID = stringr::str_extract(description, "(?<=ID=)[^;]+")) # Parse to extract gene IDs

       message(paste0('INFO: FIND GENES AROUND ', DISTANCE, ' bp from each SNP'))
  genes <-
    ttplot::get_gene_from_snp(gff.gene, outliers, distance = DISTANCE, file.save = F,) %>%
    dplyr::mutate(distance = abs(snp_location - gene_end)) %>%
    dplyr::arrange(distance)
 	message(paste0('INFO: FOUND ', nrow(genes), ' GENES'))     
  if(nrow(genes) > 0){
	message('INFO: SAVE TABLE')
    genes %<>%
      dplyr::mutate(loc = paste0(chr,':', snp_location)) %>%
      dplyr::filter(!duplicated(ID)) %>% # remove twice accounting genes
      dplyr::select(geneid, distance, snp_location, everything())
  } else {genes = NULL}

  return(genes)

}

FUN_candidate(OUTLIERS, GFF3, DISTANCE) %>%
	fwrite(OUTTABLE, sep = '\t', col.names = T, row.names = F, quote = F)
