#####
# EXAMPLE: docker run -v `pwd`:/data -w /data rstudio_eaa3 Rscript 3.GAPIT.R <OUTDIR> <PHENOTYPE.tsv> <GAPIT_GD.tsv> <GAPIT_GM.tsv> <LIST OF MODELS SEPARATED BY COMMA> <K - number of clusters>

### ARGS
# 1 - LFMM # .lfmm extension must Further can add here vcf2lfmm function to take as input only VCF #TODO 
# 2 - VCFSNP - produced after vcf2lfmm conversion
# 3 - SAMPLES list each on new line
# 4 - Phen file
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
VCFSNP = args[2] # produced after vcf2lfmm conversion
SAMPLES = args[3]
PHEN.table = args[4] # table of traits
MODELS = args[5]
PCA_total = args[6] %>% as.numeric
KINSHIP_alg = args[7]
WORKDIR = paste0(getwd(), '/', args[8]) ; mkdir(WORKDIR) # NAME OF THE DIR THAT WILL BE CREATED IN CURRENT DIRECTORY
#################################

samples = fread(SAMPLES, header = F)$V1

# Create/Load files
## GD
GD = paste0(WORKDIR, '/', NAME, '.GD')
message(paste0('INFO: LOAD GD FILE: ', GD))
if(!file.exists(GD)){
	message('INFO: THERE IS NO GD FILE -> CREATING FROM LFMM FILE')
	myGD <-
		cbind(Taxa = samples, 
		      fread(LFMM))
	message('INFO: SAVE GD FILE')
	myGD %>%
		fwrite(GD, col.names = T, row.names = F, quote = F, sep = '\t')
} else { myGD <- fread(GD, header = TRUE, sep = '\t')}

## GM
GM = paste0(WORKDIR, '/', NAME, '.GM')
message(paste0('INFO: LOAD GM FILE: ', GM))
if(!file.exists(GM)){
	message('INFO: THERE IS NO GM FILE -> CREATING FROM VCFSNP FILE')
	myGM <-
		fread(VCFSNP, sep = ' ', header = F) %>%
		dplyr::mutate(Name = paste0('V', 1:n())) %>%
		dplyr::select(Name, V1, V2) %>%
		setNames(c('Name', 'Chromosome', 'Position')) %>%
		as.data.table 
	message('INFO: SAVE GM FILE')
	myGM %>%
		fwrite(GM, sep = '\t', row.names = F, quote = F)
} else { myGM <- fread(GM, header = TRUE, sep = '\t') }

## PHEN - Y
YY = paste0(WORKDIR, '/PHENOTYPES.Y')
message(paste0('INFO: LOAD GAPIT PHENOTYPE FILE (Y): ', YY))
if(!file.exists(YY)){
	message(paste0('INFO: THERE IS NO GAPIT PHENOTYPE FILE -> CREATING FROM PHENOTYPE TABLE'))
	myY <-
		read.table(PHEN.table, sep = '\t', header = T) %>%
		cbind(Taxa = samples, .)
	message('INFO: SAVE GAPIT PHENOTYPE FILE')
	myY %>%
		write.table(YY, col.names = T, row.names = F, quote = F, sep = '\t')
} else { myY = read.table(YY, head = TRUE, sep = '\t') }

# Parameters
models <- MODELS %>% str_split(',') %>% unlist
kinship.algo <- KINSHIP_alg

# Set wd for output all files there
setwd(WORKDIR)
message(paste('INFO: WORKDIR:', getwd()))

# Run GAPIT
message('INFO: RUN GAPIT3 PIPELINE')
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
message('INFO: GAPIT3 PIPELINE FINISHED')

message('INFO: WARNINGS DURING WORK:')
warnings()


