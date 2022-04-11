#!/bin/bash

# Run in WORKDIR
#####################
R1=$1 # ChIPSeq_ES_2_CGATGT_L001_R1_001.fastq
R2=$2 # ChIPSeq_ES_2_CGATGT_L001_R2_001.fastq
BARCODES=$(realpath $3) # NAME1 BARCODE1 (.tsv)
MISMATCH=$4 # 5 norm!
BOWTIEINDEX=$(realpath $5)

CPU=$6
RAM=$7
source ${CONDA_PREFIX}/etc/profile.d/conda.sh
#####################

R1name=${R1%%.*}
R2name=${R2%%.*}

R1trim=${R1name}.trim.fastq.gz
R2trim=${R2name}.trim.fastq.gz

BARCODE1=$(cat $BARCODES | cut -f1 | head -1)
mkdir QC trim

# QC raw reads
#fastqc $R1 $R2 -t $CPU -o QC

### Trim first NNN ###
if test -f "trim/${R1trim}"; then
	echo "File trim/${R1trim} already exist - SKIP TRIMMING"
else
	fastp -w $CPU -f 3 -i $R1 -I $R2 -o trim/${R1trim} -O trim/${R2trim}
fi

cd trim

###################################
#TODO We delete file that check for BarSplit step, ADD ANOTHER CHECK
##################################
### BarcodeSpliter ###
mkdir BarSplitR1 BarSplitR2
if test -f "BarSplitR1/${BARCODE1}_R1.fastq"; then 
	echo "Barcodes already splitted - SKIP BARCODESPLITTER"
else
(echo "zcat $R1trim | BarcodeSplitter --bcfile ${BARCODES} --bol --mismatches $MISMATCH --prefix BarSplitR1/ --suffix "_R1.fastq" --debug"
 echo "zcat $R2trim | BarcodeSplitter --bcfile ${BARCODES} --bol --mismatches $MISMATCH --prefix BarSplitR2/ --suffix "_R2.fastq" --debug") | parallel
fi


conda activate fastq-pair # ! NEED fastq-pair conda enviroment with fastq_pair tool installed
rm BarSplitR1/unmatched_R1.fastq BarSplitR2/unmatched_R2.fastq

mkdir alignments QC
for barcode in `cat $BARCODES | cut -f1`
	do
	
	### READ PAIRING ###
	if test -f "BarSplitR1/${barcode}_R1.fastq.paired.fq"; then
	        echo "Files already paired - SKIP PAIRING"
	else
		fastq_pair BarSplitR1/${barcode}_R1.fastq BarSplitR2/${barcode}_R2.fastq && rm BarSplitR1/${barcode}_R1.fastq BarSplitR2/${barcode}_R2.fastq
	fi

	### TRIM barcodes ###
	if test -f "${barcode}_R1.trim.fq.gz"; then
	
		echo "Barcodes already trimmed - SKIP BARCODE TRIMMING"
	
	else	
		fastp -w $CPU -f 22 -i BarSplitR1/${barcode}_R1.fastq.paired.fq -I BarSplitR2/${barcode}_R2.fastq.paired.fq -o ${barcode}_R1.trim.fq.gz -O ${barcode}_R2.trim.fq.gz

		cat BarSplitR1/${barcode}_R1.fastq.single.fq BarSplitR2/${barcode}_R2.fastq.single.fq > ${barcode}_single.fq && rm BarSplitR1/${barcode}_R1.fastq.single.fq BarSplitR2/${barcode}_R2.fastq.single.fq

		fastp -w $CPU -f 22 -i ${barcode}_single.fq  -o ${barcode}_single.trim.fq.gz
	fi

	### FASTQC
	#fastqc $R1 $R2 -t $CPU -o QC

	### ALIGNMENT
	if test -f "alignments/${barcode}.bam"; then
		echo "${barcode} already aligned to the genome - SKIP ALIGNING"

	else
		bowtie2 --threads $CPU -x $BOWTIEINDEX -1 ${barcode}_R1.trim.fq.gz -2 ${barcode}_R2.trim.fq.gz -U ${barcode}_single.trim.fq.gz |samtools sort -@ ${CPU} | samtools view -b - > alignments/${barcode}.bam
		samtools flagstat -@ $CPU alignments/${barcode}.bam > alignments/${barcode}.flagstat
	fi
	

	### DUPLICATES
#	if test -f #TODO

	conda activate picard
	export _JAVA_OPTIONS="${RAM}"

	picard MarkDuplicates I=alignments/${barcode}.bam O=alignments/${barcode}.MD.bam M=alignments/${barcode}.MD_metrics

	### MACS2 peak calling
	#TODO	

	done
