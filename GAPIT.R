#####
# EXAMPLE: docker run -v `pwd`:/data -w /data rstudio_eaa3 Rscript 3.GAPIT.R <OUTDIR> <PHENOTYPE.tsv> <GAPIT_GD.tsv> <GAPIT_GM.tsv> <LIST OF MODELS SEPARATED BY COMMA> <K - number of clusters>

### ARGS
# 1 - WORKING DIRECTORY
# 2 - PHENOTYPE TABLE 2 column: (Genotype Phenotype) with tabular separator
# 3 - GD table (see GAPIT tutorial)
# 4 - GM table (see GAPIT tutorial)
# 5 - list of models separated by comma: BLINK,FarmCPU
# 6 - PCs number that explain population structure (often equal to K from previous step, 4 for barley)
# 7 - Kinship algorithm (VanRaden, Zhang, Loiselle and EMMA) 
########


if(!require('devtools')) install.packages('devtools'); library(devtools)
if(!require('GAPIT')) devtools::install_github("jiabowang/GAPIT", force=TRUE); library(GAPIT)
if(!require('data.table')) install.packages('data.table'); library(data.table)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('stringr')) install.packages('stringr'); library(stringr)
if(!require('icesTAF')) install.packages('icesTAF'); library(icesTAF)

args = commandArgs(trailingOnly=TRUE)
getwd()

# load files
mkdir(args[1])
myGD <- fread(args[2], header = TRUE)
myY <- read.table(args[3], head = TRUE)
myGM <- fread(args[4], header = TRUE)
# if(args[5] != 'NULL'){
myCV <- read.table(args[5], head = TRUE)
# }
models <- args[6] %>% str_split(',') %>% .[[1]]
#PCs.number <- args[7] %>% as.numeric
kinship.algo <- args[7]

# Set wd for output all files there
setwd(args[1])
print(paste('Working dir: ', getwd()))
# Run GAPIT
GAPIT(
        Y=myY,
        GD=myGD,
        GM=myGM,
        CV=myCV,
        model=models,
	#PCA.total=PCs.number,
	Model.selection=F,
        Geno.View.output=T,
        Phenotype.View=T,
	Random.model=T, # to calculate PVE (phenotype variance explained)
        NJtree.group=3,                                       # set the number of clusting group in Njtree plot
        #Inter.Plot=TRUE,                                      # perform interactive plot
        Multiple_analysis = F,                               # perform multiple analysis
        PCA.3d=F,                                          # plot 3d interactive PCA
        file.output = T,                         # plot 3d interactive PCA
	kinship.algorith = kinship.algo
      )

warnings()
