
library(dplyr)
library(magrittr)
library(data.table)
library(WGCNA)
library(vegan)
library(ggplot2)
library(robust)
library(qvalue)

args = commandArgs(trailingOnly=TRUE)
#################################
LFMM_imp = args[1]
PREDICTORS = read.table(args[2], sep = '\t', header = T)
COVARIATES = read.table(args[3], sep = '\t', header = T)
SNPS = fread(args[4], sep = ' ', header = T)
OUTSUFFIX = args[5]
#################################

#### Function to conduct a RDA based genome scan from Capblancq et al. (2018)
rdadapt <- function(rda,K)
{
  zscores<-rda$CCA$v[,1:as.numeric(K)]
  resscale <- apply(zscores, 2, scale)
  resmaha <- covRob(resscale, distance = TRUE, na.action= na.omit, estim="pairwiseGK")$dist
  lambda <- median(resmaha)/qchisq(0.5,df=K)
  reschi2test <- pchisq(resmaha/lambda,K,lower.tail=FALSE)
  qval <- qvalue(reschi2test)
  q.values_rdadapt<-qval$qvalues
  return(data.frame(p.values=reschi2test, q.values=q.values_rdadapt))
}


FUN_rda <- function(LFMM_imp,  # X
                    predictors, # Y
                    covariates, # Z -> NULL if no correction
                    snps,
                    model.name = "RDA.model",
                    K = ncol(predictors), # number of RDA takes into analysis (too many may lead to overfiting)
                    pval = 0.05,# before bonferonni correction
                    sd_num = 3, # only for situation with 1 predictor
                    permutation_num = 999,
                    only_basic = F,
                    check_significance = F){ # long execution

  # Load imput lfmm
                                                                                                  message('READ LFMM: START')
  lfmm_imp <-
    fread(LFMM_imp)
                                                                                                  message('READ LFMM: FINISH')
  
  # Run model
                                                                                                  message('RDA: START')
  if(is.null(covariates)){ # No correction for pop structure
  
                                                                                                  message('RDA: WITH NO CORRECTION')    
    formul = paste0(
      'lfmm_imp ~ ', # response
      paste(colnames(predictors), collapse = ' + '))  # predictors
                                                                                                  message(formul[[1]])
     rda.p <- rda(formula(formul), data = predictors)
     
  } else { # With correction for covariates
    
                                                                                                    message('RDA: WITH CORRECTION')    
    formul = formula(paste0(
      'lfmm_imp ~', # response
      paste(colnames(predictors), collapse = ' + '),  # predictors
      ' + Condition(', paste0(colnames(covariates), collapse = ' + '), ')')) # Covariates
    rda.p <- rda(formul, data = cbind(predictors, covariates))
    
  }
    # stopifnot(!is.null(rda.p))
                                                                                                    message(paste0('RDA MODEL IS NULL: ', is.null(rda.p)))
                                                                                                      message('RDA: FINISH')
    # lfmm_imp ~ predictors + Condition(covariates))
                                                                                                      message('RDA OUTLIERS DETECTION: START')
  # Extract data
  data <- scores(rda.p, type="n", scaling=3) %>% lapply(as.data.frame)
  
  # Outlier detection
  if(ncol(predictors) > 1){
      
                                                    message(paste0('RDA: ', ncol(predictors), ' predictors and ', K, 'RDAs'))
        rdadapt.res <- rdadapt(rda.p, K)
        gLOADINGS_HIST = NULL #####################
      
  } else { # If we have only 1 predictors we can't use function rdadapt, and estimate outliers and p.values in another way
                                                                                                    message('RDA: 1 predictor')
        
        load.rda <- rda.p$CCA$v[,1]
        
        gLOADINGS_HIST <-  ##################
          as.ggplot(function() hist(load.rda, main="Loadings on RDA1") )
        
        # outliers_sd <- loadings_outliers(load.rda, sd_num) # 38
        # Calculate z-scores
        z_scores <- scale(load.rda, center = mean(load.rda), scale =  sd(load.rda))
        # Calculate two-tailed p-values - min between left and right tailed multiplied by 2
        p_values_two_tailed <- 2 * pmin(pnorm(z_scores, lower.tail = TRUE), 
                                        pnorm(z_scores, lower.tail = FALSE))
        rdadapt.res <- data.frame(p.values = p_values_two_tailed[,1])
  }
  
  
    ## Use Bonferroni for correction
    ## P-values threshold after Bonferroni correction
    rdadapt.thres <- pval / length(rdadapt.res$p.values)
    # Use FDR 
    # rdadapt.thres <- rdadapt.res$p.values[rdadapt.res$q.values < pval] %>% max
    ## Identifying the loci that are below the p-value threshold
    outliers <- data.frame(Loci = colnames(lfmm_imp)[which(rdadapt.res$p.values < rdadapt.thres)], 
                           p.value = rdadapt.res$p.values[which(rdadapt.res$p.values < rdadapt.thres)])
    # save for 3d biplot
    locus_scores <- scores(rda.p, choices=c(1:K), display="species", scaling="none") # extract again but without scaling?
    TAB_loci <- data.frame(Loci = row.names(locus_scores), locus_scores)
    TAB_loci <- ##############
      TAB_loci %>%
      dplyr::mutate(p.value = rdadapt.res$p.values,
                    q.value = qvalue(rdadapt.res$p.values)$qvalue) %>%
      dplyr::mutate(type = ifelse(p.value < rdadapt.thres, 'Outlier', 'Neutral') %>% as.factor) %>%
      cbind(snps, .) #%T>%
      # write.table(paste0(OUTTABLES, 'RDA_SNPs_shpere_', model.name, '.tsv'), quote = F, row.names = F, col.names = T, sep = '\t')
    
    if(only_basic){
      return(TAB_loci)
    }
                                                                                                            message(paste0('RDA OUTLIERS DETECTION: FINISH: ', ncol(outliers)))
  
                                                                                                            message('RDA MODEL ASSESMENT: START')
  # Assessment
    ## screeplot
                                                                                                            message('RDA MODEL ASSESMENT: SCREEPLOT')
    # gSCREE <- as.ggplot(function() screeplot(rda.p, main="Eigenvalues of constrained axes"))   #######################
                                                                                                            message('RDA MODEL ASSESMENT: CUMSUM')
    ## Cumsum - to Decide how many RDAs to use
    ## Note that choosing too many axes may result in overfitting
    # rda.eigv <- a$y # save this it's the eigenvalues
    # prop_var <- round(rda.eigv / sum(rda.eigv), 3)
    #                                                                                                         
    # gCUMSUM <- as.ggplot(function() {                                                       #############################
    #   plot(cumsum(prop_var), xlab="Number of RDA axes",  # plot cumsum of var explained of each RDAs
    #        ylab="Cumulative percent of variation explained", ylim=c(0,1))
    #       })
    
    gSCREE <- NULL #TODO
    gCUMSUM <- NULL
  # VIF
                                                                                                            message('RDA MODEL ASSESMENT: VIF')
    vif <- vif.cca(rda.p) #TODO returт it somewhere
                                                                                                                      
    
                                                                                                            message('RDA MODEL ASSESMENT: REVERSE PREDICT')
  # Predict predictors values de novo :)
    pred.names <- rda.p$CCA$biplot %>% row.names # extract names of predictors in the same order as in the model (probably it's always the same as in 'predictors' input argument, but it's reinsurance)
    # biplot.RDAs.number = summary(rda.p$model)$biplot %>% ncol
    
    reverse.predict <-
      mclapply(1:K, function(n){
        
        traitPred <- rda_trait_pred(rda.p, n, K) # second argument is the row in rda.pc$CCA$biplot
        # Empirical study could compare an empirically measured trait value 
        # to the RDA-predicted trait value to test how well landscape genomic data 
        # can predict functional traits
        cor.value = cor(predictors[[n]], traitPred)
        
        gCORPLOT = as.ggplot(function() {
          plot(predictors[[n]], traitPred, xlab = pred.names[n],
               ylab="RDA trait prediction", main = paste0('Correlation: ', round(cor.value, 3)))
          abline(0,1)
        })
        
        return(gCORPLOT)
    
      }, mc.cores = CPU) %>% setNames(pred.names)
      
                                                                                                                     message('RDA MODEL ASSESMENT: FINISH')
                                                                                                                     
  if(ncol(predictors) > 1 & length(outliers$Loci) > 1){
                                                                                                                     message('RDA LOCI COEFFICIENT ESTIMATION: START')
  # Coefficients
    ## It may be interesting for some studies to understand how each locus is shaped by the environment - in other words, what are the slopes associated with the environmental variables in the multiple regression model for each locus?

    ## Unfortunately there is not a way to output these slopes in the R package vegan, but we can reproduce the first step of the RDA to get the regression coefficients: (vegan source code at https://github.com/cran/vegan/blob/master/R/simpleRDA2.R)
    # Decomposition
    Q = qr(predictors, tol = 1e-6)
    # Get the matrix of regression coefficients
    Qr.coeff <- qr.coef(Q, as.matrix(lfmm_imp))
    # This matrix has each SNP in a column and the regression coefficients for that SNP corresponds to each environmental variable. This is the step that is not performed in the `vegan` package - the package skips directly to predicting the fitted values, on which the ordination is performed.
    # We can visualize the regression coefficients with a heatmap for candidate loci
    # Extract coefficients and arrange
    rda.coeff <- #################
      Qr.coeff[, outliers$Loci] %>%
      t %>%
      as.data.table %>%
      dplyr::mutate(SUM = rowSums(abs(.)),
                    snp = outliers$Loci) %>%
      dplyr::arrange(desc(SUM)) %>% 
      dplyr::select(snp, everything())
    ## Based on this range choose color breaks for heatmap
    coef_range <- 
      Qr.coeff[, outliers$Loci] %>% 
        as.numeric %>%
        summary
    
    brks <- seq(coef_range[1], coef_range[6], by=0.05) #set the color scale
                                                                                                  message('RDA LOCI COEFFICIENT ESTIMATION: FINISH')
    gCOEFHEATMAP <- ###############
      as.ggplot(function() {
        heatmap.2(t(Qr.coeff[, outliers$Loci]),
          scale="none", 
          col = cm.colors(length(brks)-1), 
          breaks=brks,
          dendrogram = "both",
          Rowv=TRUE, 
          trace="none",
          key.title = "Coefficient in multiple\nregression model",
          ylab="SNPs",
          cexCol=1)
      })
                                                                                                   
  } else {
    gCOEFHEATMAP = NULL
    rda.coeff = NULL
  }
                                                                                                   
                                                                                                    
                                                                                                   message('RDA ANALYSING RESULTS: FINISH')
  # Significance
    # We can **assess both the full model and each constrained axis using F-statistics** (Legendre et al, 2010). 
    # The output looks a lot like an ANOVA table and the function is even called anova, but in fact it is a permutation test, in which the rows of the unconstrained matrix are randomized repeatedly across some number of permutations. If the observed relationship is stronger than the randomly permuted relationships (e.g. at alpha = 0.05), then the relationship is significant.
    # The null hypothesis is that no linear relationship exists between the SNP data and the environmental predictors
    
                                                                                                    
    if(check_significance){
                                                                                                    message('RDA MODEL SIGNIFICANCE: START')
      # Full model significance
        signif.full <- anova.cca(rda.p,
                              parallel=CPU,
                              permutations = permutation_num)
  
      ## RDA axis significance
        ## We can **check each constrained axis for significance**.
        ##For this test, **each constrained axis is tested using all previous constrained axes as conditions**.
        signif.axis <- anova.cca(rda.p,
                             by="axis",
                             parallel=CPU,
                             cutoff = 0.01,
                             permutations = permutation_num)
      ## Variable significance
        signif.vars <- anova.cca(rda.p,
                                 by="term",
                                 parallel=CPU,
                                 permutations = permutation_num)
                                                                                                              message('RDA MODEL SIGNIFICANCE: FINISH')
        significance <-
          list(full = signif.full,
             axis = signif.axis,
             vars = signif.vars)
                                                                                                    
    } else {significance = NULL}
    
  # Basic plots
    
    TAB_samples <- cbind(data$sites, predictors) #############
    
    ## Samples
    if(ncol(predictors) > 1){
      
     gSAMPLES  <- #############
        lapply(colnames(predictors), function(pred.name){
        
          ggplot(TAB_samples,
                 aes_string(x = 'RDA1', y = 'RDA2', color = pred.name)) +
            geom_point() +
            scale_color_viridis_c(option = "plasma") +
            plot_theme
        }) %>% setNames(colnames(predictors))
     
    } else { gSAMPLES <- NULL }
    
    ## SNPs 
      if(ncol(predictors) > 1 & length(outliers$Loci) > 1){
                                                                                                    message('RDA CORRELATION OUTLIER LOCI WITH PREDICTORS: START')
      ### Assign each SNP to predictor
      cor.list <-
        mclapply(outliers$Loci, function(snp) {
          lapply(colnames(predictors), function(env){
            WGCNA::cor(lfmm_imp[[snp]],
                      predictors[[env]], 
                      method = 'spearman')
          }) %>% 
            unlist
        }, mc.cores = CPU)
      
      
      cor.df <-
        sapply(1:length(cor.list[[1]]), function(i) {
           sapply(1:length(cor.list), function(j) { cor.list[[j]][i] } )
         })  %>%
          as.data.frame %>%
          setNames(colnames(predictors)) %>%
        dplyr::mutate(Cor.Main = sapply(cor.list, function(vec) colnames(predictors)[which.max(abs(vec))])) %>%
        cbind(outliers) %>%
        dplyr::select(-p.value)
    
      # Manhattan
      gMANHAT <- #################
        as.ggplot(function() {
          TAB_loci %>%
            dplyr::mutate(CHROM = gsub('chr|H', '', CHROM) %>% as.numeric) %>%
            qqman::manhattan(chr = 'CHROM', bp = 'POS', p = 'p.value', snp = 'Loci', 
                             highlight = outliers$Loci ,
                             suggestiveline = F, genomewideline = -log10(rdadapt.thres))
        })
      
      #TODO Add to TAB_loci
      # { if(ncol(predictors) > 1) left_join(., cor.df, by = 'Loci') else .  } %>% 
      
      TAB_var <- ##############
        as.data.frame(scores(rda.p, choices=c(1:3), display="bp")) %T>%
        write.table(paste0(OUTTABLES, 'RDA_SNPs_sphere_Vectors_', model.name, '.tsv'), sep = '\t')# pull the biplot scores
      
      
                                                                                                  message('RDA CORRELATION OUTLIER LOCI WITH PREDICTORS: FINISH')
      } else { cor.df = NULL; TAB_loci = NULL; TAB_var = NULL; gMANHAT = NULL}
    
    
      
   # gSNPs <-
   #      ggplot(data$species,
   #             aes(x = RDA1, y = 'RDA2', color = pred.name)) +
   #        geom_point() +
   #        scale_color_viridis_c(option = "plasma") +
   #        plot_theme
   #    }) %>% setNames(colnames(predictors))
   
   
  return(list(model = rda.p,
              coefficients = list(heatmap = gCOEFHEATMAP,
                                  value = rda.coeff),
              characteristics = list(screeplot = gSCREE,
                                     hist = gLOADINGS_HIST,
                                     cumsum = gCUMSUM,
                                     vif = vif,
                                     reverse.predict = reverse.predict,
                                     significance = significance
                                     ),
              plots = list(samples = gSAMPLES,
                           manhat = gMANHAT),
              values = list(loci = TAB_loci,
                             outliers = outliers,
                            samples = TAB_samples,
                            bp = TAB_var,
                            pval = pval,
                            pval.adj = rdadapt.thres
                            )
              )
        )
}


########################################################################## RUN #################################################################################
FUN_rda(LFMM_imp, PREDICTORS, COVARIATES, SNPS, OUTSUFFIX,
	only_basic = T) %>%
fwrite(paste0(OUTSUFFIX, '.tsv'), sep = '\t', col.names = T, row.names = F, quote = F)


