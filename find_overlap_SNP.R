
library(dplyr, quietly = T)
library(data.table, quietly = T)
library(GenomicRanges, quietly = T)
args = commandArgs(trailingOnly=TRUE)

#############
FILENAMES = args[1:(length(args) - 2)]
OVERLAPGAP = args[length(args) - 1] %>% as.numeric
OUTSUFFIX = args[length(args)]  
#############

message(paste('INFO: FINDING OVERLAPS WITH GAP ', OVERLAPGAP, 'bp BETWEEN FILES:'))
message(paste(FILENAMES, collapse = ' '))

find_overlaps <- function(file1, file2, N) {
  # Read data from the files
  gr1 <- read.table(file1, header = TRUE, colClasses = c("character", "numeric"))
  gr2 <- read.table(file2, header = TRUE, colClasses = c("character", "numeric"))
  # Create pval column if it's doesnt exist
  if(is.null(gr1$pval)){ gr1$pval = rep(1, nrow(gr1)) }
  if(is.null(gr2$pval)){ gr2$pval = rep(1, nrow(gr2)) }

  # Create GRanges objects
  granges1 <- GRanges(seqnames = gr1$CHROM, ranges = IRanges(start = gr1$POS, end = gr1$POS))
  granges2 <- GRanges(seqnames = gr2$CHROM, ranges = IRanges(start = gr2$POS, end = gr2$POS))

  # Find overlaps
  overlaps <- findOverlaps(granges1, granges2, maxgap = N - 1) %>% as.data.frame
  if(nrow(overlaps) == 0){ return(NULL)} # stop if there is no overlaps

  # Extract overlapping data	 
  overlaps_dt <- data.table(chr1 = gr1$CHROM[overlaps$queryHits],
		     	pos1 = gr1$POS[overlaps$queryHits],
		     	filename1 = rep(file1, nrow(overlaps)),
			pval1 = gr1$pval[overlaps$queryHits],
		    	chr2 = gr2$CHROM[overlaps$subjectHits],
		     	pos2 = gr2$POS[overlaps$subjectHits],
		     	filename2 = rep(file2, nrow(overlaps)),
			pval2 = gr2$pval[overlaps$subjectHits]
			)
  return(overlaps_dt)
  }

# Get all combinations without repeats
all_combinations <- combn(FILENAMES, 2, simplify = FALSE)

message(all_combinations)

dt <-
	lapply(all_combinations, function(filepair){
		       
		       find_overlaps(filepair[1], filepair[2], OVERLAPGAP)
		       
  }) %>%
	do.call(rbind, . )

message(paste('INFO: SAVE OUT TABLE TO', paste0(OUTSUFFIX, '.tsv'), 'FILE'))
dt %>%
	write.table(paste0(OUTSUFFIX, '.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)
