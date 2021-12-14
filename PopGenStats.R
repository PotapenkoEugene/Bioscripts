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
?vcfR::read.vcfR
vcf <- read.vcfR(path, verbose = FALSE, limit = 1.2e+11) # limit on hive server based 120gb
snp <- vcfR2genind(vcf)

# Population have to be specified in that format: POP_IND
# ! SCRIPT JUST GET 1 and 2 char for pop number
snp$pop <-  as.factor(substr(row.names(snp$tab), 1,2))

## **Missing data: loci**
# Calculate the percentage of complete genotypes per loci 
locmiss_snp = propTyped(snp, by = 'loc')
print(paste0('INFO:    The percentage of uncomplete genotypes per loci(<0.80):    ', locmiss_snp[which(locmiss_snp < 0.80)]))
# Remove loci with a lot of miss data
snp = missingno(snp, type='loci', cutoff=0.20)
# Remove ind with a lot of miss data
snp = missingno(snp, type='geno', cutoff=0.20)

## Check genotypes are unique
# Print the number of multilocus genotypes
mlg(snp)
# Identify duplicated genotypes.
dups_snps = mlg.id(snp)
print('INFO:    Remove duplicated individuals:')
dupls = c()
for (i in dups_snps){ # for each element in the list object
  if (length(dups_snps[i]) > 1){ # if the length is greater than 1
    dupls = c(dupls, i)
    }
}

# Remove duplicated genotypes.
# Create a vector of individual names without the duplicates
snp_Nodups = indNames(snp)[! indNames(snp) %in% dupls]
# Create a new genind object without the duplicates
snp = snp[snp_Nodups, ]
mlg(snp)


## **Check loci are still polymorphic after filtering**
print('INFO:    Check loci that polymorphic')
isPoly(snp) %>% summary

print('INFO:    Remove loci that are not polymorphic.')
poly_loci = names(which(isPoly(snp) == TRUE))
snp = snp[loc = poly_loci]

print('INFO:    Check loci that polymorphic again')
isPoly(snp) %>% summary

print('INFO:    Summary statistics')
print('INFO:    Mean allelic richness per site across all loci')
allelic.richness(genind2hierfstat(snp))$Ar %>%
  apply(MARGIN = 2, FUN = mean) %>% 
  round(digits = 3)

print('INFO:    Calculate heterozygosity per site')
# Calculate basic stats using hierfstat
basic_snp = basic.stats(snp, diploid = TRUE)
# Mean observed heterozygosity per site
Ho = apply(basic_snp$Ho, MARGIN = 2, FUN = mean, na.rm = TRUE)
Ho

print('INFO:    Mean expected heterozygosity per site')
He = apply(basic_snp$Hs, MARGIN = 2, FUN = mean, na.rm = TRUE) %>% round(digits=3)
He

print('INFO:    Inbreeding coefficient (FIS)')
print('INFO:    Calculate mean FIS per site')
apply(basic_snp$Fis, MARGIN = 2, FUN = mean, na.rm = TRUE) %>%
  round(digits = 3)

print('INFO:    Compute pairwise FST (Weir & Cockerham 1984).')
fst = genet.dist(snp, method = "Fst")
fst %>% round(digits = 3)







