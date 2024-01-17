#####
# EXAMPLE: docker run -v `pwd`:/data -w /data rstudio_eaa3 Rscript 3.GAPIT.R <OUTDIR> <PHENOTYPE.tsv> <GAPIT_GD.tsv> <GAPIT_GM.tsv> <LIST OF MODELS SEPARATED BY COMMA> <K - number of clusters>

### ARGS
# 1 - LFMM # .lfmm extension must Further can add here vcf2lfmm function to take as input only VCF #TODO 
# 2 - VCF - grep -v '#'' VCF | cut -f1-9 
# 3 - Samples 
# 4 - Phen file with 1 trait (column)
# 5 - MODELS - list of models separated by comma: BLINK,FarmCPU,SUPER...
# 6 - PCs number that explain population structure
# 7 - Kinship algorithm (VanRaden, Zhang, Loiselle and EMMA)
# 8 - Working directory


if(!require('devtools')) install.packages('devtools'); library(devtools)
if(!require('GAPIT')) devtools::install_github("jiabowang/GAPIT", force=TRUE); library(GAPIT)
if(!require('data.table')) install.packages('data.table'); library(data.table)
if(!require('dplyr')) install.packages('dplyr'); library(dplyr)
if(!require('stringr')) install.packages('stringr'); library(stringr)
if(!require('icesTAF')) install.packages('icesTAF'); library(icesTAF)

args = commandArgs(trailingOnly=TRUE)
getwd()

# Parse arguments
LFMM = args[1] ; NAME = gsub('.lfmm', '', LFMM)
VCF = args[2]
SAMPLES = read.table(args[3], head = F)
PHEN.table = args[4] # table of traits
PHEN.name = args[5] # name of desired trait from PHEN.table to analyze
MODELS = args[6]
PCA_total = args[7] %>% as.numeric
KINSHIP_alg = args[8]
WORKDIR = args[9] ; mkdir(WORKDIR)

# Set wd for output all files there
setwd(WORKDIR)
message(paste('INFO: WORKDIR:', getwd()))

# Create/Load files
## GD
GD = paste0(NAME, '.GD')
if(!file.exists(GD)){
	cbind(Taxa = SAMPLES, 
	      fread(LFMM)) %>%
	fwrite(GD, col.names = T, row.names = F, quote = F, sep = '\t')
} else { myGD <- fread(GD, header = TRUE, sep = '\t')}

## GM
GM = paste0(NAME, '.GM')
if(!file.exists(GM)){
	myGM <-
		fread(cmd = paste('grep -v \"##\"', 
			  VCF, 
			  '| cut -f1-9')) %>%
		setNames(gsub('#', '', colnames(.))) %>%
		dplyr::mutate(Name = paste0('V', 1:n())) %>%
		dplyr::select(Name, CHROM, POS) %>%
		setNames(c('Name', 'Chromosome', 'Position')) %>%
		as.data.table 
	
	myGM %>%
		fwrite(GM, sep = '\t', row.names = F, quote = F)
} else { myGM <- fread(GM, header = TRUE, sep = '\t')

## PHEN - Y
YY = paste0(PHEN.name, '.Y')
if(!file.exists(YY)){
	phen <-
		read.table(PHEN.table, sep = '\t', header = T) %>%
		dplyr::select(!!PHEN.name) %>%
		cbind(Taxa = SAMPLES, .)
	phen %>%
		write.table(YY, col.names = T, row.names = F, quote = F, sep = '\t')

} else { read.table(YY, head = TRUE, sep = '\t') }

# Parameters
models <- MODELS %>% str_split(',') %>% unlist
kinship.algo <- KINSHIP_alg

# Set wd for output all files there
setwd(WORKDIR)
message(paste('INFO: WORKDIR:', getwd()))

# Run GAPIT
GAPIT(
        Y=myY,
        GD=myGD,
        GM=myGM,
        model=models,
	PCA.total=PCA_total,
	Model.selection=F,
        Geno.View.output=T,
        Phenotype.View=T,
	Random.model=T, # to calculate PVE (phenotype variance explained)
        #NJtree.group=3,                                       # set the number of clusting group in Njtree plot
        #Inter.Plot=TRUE,                                      # perform interactive plot
        Multiple_analysis = F,                               # perform multiple analysis
        PCA.3d=F,                                          # plot 3d interactive PCA
        file.output = T,                         # plot 3d interactive PCA
	kinship.algorith = kinship.algo
      )

warnings()
