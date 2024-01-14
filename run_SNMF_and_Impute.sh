NAME=$1
Rscript ../SNMF.R ${NAME}.geno 3 3 3 140
Rscript ../Impute.R ${NAME}.snmfProject ${NAME}.lfmm 3
