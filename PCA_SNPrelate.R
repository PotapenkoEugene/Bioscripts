args <- commandArgs(trailingOnly = TRUE)
In=args[1] 	# path to VCF input file
Tag=args[2]	# Prefix

library(RColorBrewer)
library(SNPRelate)

snpgdsVCF2GDS(In, paste(Tag,".gds",sep=""))
GDS <- paste(Tag,".gds",sep="")
organGDS <- snpgdsOpen(GDS)
organ.PCA<-snpgdsPCA(organGDS, autosome.only=FALSE, num.thread = 32)

organPCA<-data.frame(sample.id=organ.PCA$sample.id, EV1=organ.PCA$eigenvect[,1], EV2=organ.PCA$eigenvect[,2],EV3=organ.PCA$eigenvect[,3],EV4=organ.PCA$eigenvect[,4],EV5=organ.PCA$eigenvect[,5],stringsAsFactors=FALSE)

print(organ.PCA$varprop[1:5] * 100)

write.table(organPCA, 
	    paste(Tag,".PCA.txt", sep=""),
	    col.names = T,
            quote = FALSE, 
	    row.names = FALSE, 
	    sep="\t")
