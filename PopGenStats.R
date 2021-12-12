r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("adegenet", quietly = TRUE)) BiocManager::install("adegenet")
if (!requireNamespace("poppr", quietly = TRUE)) install.packages("poppr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("hierfstat", quietly = TRUE)) install.packages("hierfstat")
if (!requireNamespace("reshape2", quietly = TRUE)) install.packages("reshape2")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("RColorBrewer", quietly = TRUE)) install.packages("RColorBrewer")
if (!requireNamespace("scales", quietly = TRUE)) install.packages("scales")

library(adegenet)
library(poppr)
library(dplyr)
library(hierfstat)
library(reshape2)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(vcfR)

args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
}
path = args[1]
outpath = args[2]

vcf <- read.vcfR(path, verbose = FALSE)
snp <- vcfR2genind(vcf)

# Population have to be specified in that format: POP_IND
# ! SCRIPT JUST GET 1 and 2 char for pop number
snp$pop <-  as.factor(substr(row.names(snp$tab), 1,2))

## **Missing data: loci**
# Calculate the percentage of complete genotypes per loci 
locmiss_snp = propTyped(snp, by = 'loc')
print(paste0('INFO:    The percentage of uncomplete genotypes per loci(<0.80):    ', locmiss_snp[which(locmiss_snp < 0.80)]))
# Remove loci with a lot of miss data
snp = missingno(snp, type='loci', cuttof=0.20)




