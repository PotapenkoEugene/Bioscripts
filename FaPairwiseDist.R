r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)
############################################################################
if (!requireNamespace("seqinr", quietly = TRUE)) install.packages("seqinr")
library(seqinr)
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
library(ggplot2)
############################################################################

args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out"
}

# Args
path = args[1]
outpath = args[2]

#############################################################################
myseqs <- read.alignment(path, format = "fasta")
mat <- dist.alignment(myseqs, matrix = "identity")

# Save DISTANCE matrix
out = paste0(outpath, '_DistMatrix.tsv')
write.table(as.matrix(mat), out, quote = FALSE, sep='\t')
#############################################################################

# Make PcoA from dist matrix
# Use Stat Quest pipeline: https://www.youtube.com/watch?v=pGAUHhLYp5Q
mds <- cmdscale(mat, eig=T, x.ret=T)
mds.var.per = round(mds$eig / sum(mds$eig)*100, 1)
# Format pca data for plotting
mds.values = mds$points
mds.data = data.frame(Sample = rownames(mds.values), 
                      X = mds.values[,1], # PC1 and PC2
                      Y = mds.values[,2])

# B_ceiba-49108_K2_d_RLK-Pelle_DLSV_Pseudo
# Make graph  (I'm a GOD of regex!)
mds.data$Species = sub('(.*)-[0-9]+.*', '\\1', mds.data$Sample)
mds.data$TK = sub('.*-([0-9]+)_K.*', '\\1', mds.data$Sample)
mds.data$KinPos = sub(".*_.*_(K[0-9])_.*", "\\1", mds.data$Sample)
mds.data$Pseudo = sub('[^_]*_[^_]*_[^_]*_[^_]*_[^_]*_[^_]*_([A-Z]*)', '\\1', mds.data$Sample)

out = paste0(outpath, '_MDSplor.png')
png(file=out, width = 2400, height = 1200)

ggplot(mds.data) +
  geom_point(aes(X,Y,shape = KinPos, color = Pseudo), size = 5)

dev.off()
