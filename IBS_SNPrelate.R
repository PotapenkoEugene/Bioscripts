args <- commandArgs(trailingOnly = TRUE)
In=args[1] 	# path to VCF input file
Tag=args[2]	# Prefix

library(RColorBrewer)
library(SNPRelate)

snpgdsVCF2GDS(In, paste(Tag,".gds",sep=""))
GDS <- paste(Tag,".gds",sep="")
oGDS <- snpgdsOpen(GDS)

# perform identity-by-state calculations
ibs <- snpgdsIBS(oGDS)
write.tsv(ibs$ibs, paste0(Tag,'_IBS.tsv'))

# close the file
snpgdsClose(oGDS)