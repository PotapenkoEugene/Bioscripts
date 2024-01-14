
VCF=$1; VCF_name=$(basename $VCF .vcf)
THIN=$2 # desired final number of SNPs

plink --allow-extra-chr --double-id --set-missing-var-ids @:# --vcf $VCF --thin-count $THIN --recode vcf --out ${VCF_name}.thinned
