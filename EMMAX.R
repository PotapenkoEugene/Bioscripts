library(dplyr)
library(data.table)
library(magrittr)

args = commandArgs(trailingOnly=TRUE)
VCF=args[1]
trait=fread(args[2], sep = '\t', header = T) # MAKE SURE THAT SAMPLES IN THE SAME ORDER AS IN VCF
covariates=fread(args[3], sep = '\t', header = T) # MAKE SURE THAT SAMPLES IN THE SAME ORDER AS IN VCF
OUT=args[4]

FUN_emmax <- function(VCF,  #TODO everytime make convertion of input file, should create separate function
                      trait, # Trait (1 col df)
                      covariates, # NULL if not use correction
		      OUT,
                      kinship = T, # use kinship correction
                      force = F){

  f = paste0(gsub('.vcf', '', basename(VCF)))
  tfam = paste0(f, '.tfam')
  kinship.f = paste0(f, '.aIBS.kinf')
  
#  snps.full = fread(cmd = paste0('grep -v \"##\"', VCF, '| cut -f1-9')) %>%
 #   setNames(gsub('#', '', colnames(.)))
  SampleName = fread(cmd = paste("head -1000", VCF, "| grep \'#CHROM\' | cut -f10- "), header = F) %>%
    as.character()

  if(!file.exists(kinship.f) | force){
                                                                                                                      message(paste0('EMMAX: Create ',f,' file'))

    # Prepare TPED/TFAM files
    system(paste0('plink --vcf ', VCF,
                  '  --allow-extra-chr --recode12 transpose --output-missing-genotype 0 --out ', f))
    # Edit family and individual names in .tfam
    system(paste("cat", tfam, " | awk \'{ print $1 \"_\" $2, $1 \"_\" $2,$3,$4,$5,$6}\' > tmp.tfam ; mv tmp.tfam ", tfam))
                                                                                                                  message(paste0('EMMAX: Calculate kinship matrix'))
    # Run Kinship matrix calculation
    system(paste('./emmax-kin-intel64 -v -s -d 10 -x', f))
  }

  # FILES produced
  traitname = colnames(trait)[1]
  PHEN = paste0(OUT,'_EMMAX_phenotype_', '_', traitname, '.tsv')
  COVAR = paste0(OUT,'_EMMAX_covariates_', '_', traitname, '.tsv')
  EMMAXOUT = paste0(OUT,'_EMMAX_OUT_', traitname)
	
  # Prepare phenotype file
  emmax.phen <-
    trait %>%
    dplyr::mutate(FAMID = SampleName,
                  INDID = SampleName) %>%
    dplyr::select(FAMID, INDID, everything()) %T>%
    write.table(PHEN, sep = '\t', col.names = F, row.names = F, quote = F)

  if(!is.null(covariates) & !is.null(kinship)){
                                                                                      message('RUN emmax with PCA and kinship corrections')

    # Prepare CV file
    emmax.phen %>%
      dplyr::select(FAMID, INDID) %>%
      dplyr::mutate(smth = 1) %>%
      cbind(covariates) %>%
      write.table(COVAR, sep = '\t', col.names = F, row.names = F, quote = F)

    # Run EMMAX
    system(paste('./emmax-intel64 -v -d 10 -t', f, 
		 ' -p', PHEN,
		' -k', kinship.f, 
		'-c', COVAR,
                 '-o', EMMAXOUT)
           )
  }

  if(is.null(covariates) & !is.null(kinship)){

                                                                                              message('RUN emmax without PCA correction')
      # Run EMMAX
    system(paste('./emmax-intel64 -v -d 10 -t', f, 
		 ' -p', PHEN,
		 '-k', kinship.f,
                 '-o', EMMAXOUT)
           )

  }

  if(is.null(covariates) & is.null(kinship)){
                                                                                  message('RUN emmax without PCA and kinship corrections')

      # Run EMMAX
    system(paste('./emmax-intel64 -v -d 10 -t', f, 
		 ' -p', PHEN,
                 '-o', EMMAXOUT)
           )

  }

  EMMAXOUT.ps = paste0(EMMAXOUT, '.ps')

  # load df
  df <-
    fread(EMMAXOUT.ps) %>%
    setNames(c('SNPID', 'beta', 'SE.beta', 'pval')) %>%
    dplyr::mutate(SNPID = paste0('V', 1:nrow(.)))

  df %>%
	  fwrite(paste0(EMMAXOUT,'.tsv'), col.names = T, row.names = F, quote = F, sep = '\t')
}

# Run each trait one by one
for(i in 1:ncol(trait)){
	FUN_emmax(VCF, trait[, ..i], covariates, OUT)
}

