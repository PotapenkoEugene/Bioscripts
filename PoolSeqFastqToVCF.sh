#!/bin/bash

####### 
# Pos arguments:
# 1) Dir
# 2) Path to reference genome
# 3) Thread number
# 4) max RAM
#######

#### TODOlist
# RAM for java estimate mb make another pos arg

# Можно добавить prefetch , fastq-dump --split-3, gzip

####
DIRPATH=$1
GENOME=$2
THREADS=$3
RAM=${4}G

# index genome
samtools faidx $GENOME
BWAINDEX=$(echo $GENOME| cut -f1 -d '.') # remove format
bwa index $GENOME -p $BWAINDEX


QC_OUTDIR='QC'


# fastp
mkdir fastp, alignment
for file in $R1PATH
do
basename=$(echo $file | cut -f1 -d '_')
FL1=$({$basename}_1.fastq)
FL2=$({$basename}_2.fastq)
# Make QC
fastqc $FL1 $FL2 -t $THREADS -o $QC_OUTDIR
fastp -i $FL1 -I $FL2 -o fastp/{$basename}_1.tr.fq -O fastp/{$basename}_2.tr.fq -w $THREADS
# Make QC
fastqc $FL1 $FL2 -t $THREADS -o $QC_OUTDIR
echo '${basename} done'
done

R1TRIMMED='fastp/*_1.tr.fq'
 

# For read groups
declare -i count=1

for file in $R1TRIMMED
do
basename=$(echo $file | cut -f1 -d '_')
FL1=$({$basename}_1.tr.fq) # basename with path to file
FL2=$({$basename}_2.tr.fq)
# Make QC
fastqc $FL1 $FL2 -t $THREADS -o $QC_OUTDIR
# ALIGN -P for paired, -M for mark shorter splits (needed for Picard)
bwa mem -t $THREADS -P -M $GENOME  $FL1 $FL2 > alignment/{$basename}.sam
# convert to bam

samtools view -@ $THREADS -b alignment/{$basename}.sam > alignment/{$basename}.bam
rm -rf {$basename}.sam
# Sorting and adding read group information
# GATK require RG info ID, PU, SM, PL, LB
mkdir alignment/RG
java -jar /home/gene/Tools/picard/build/libs/picard.jar AddOrReplaceReadGroups \
I=alignment/{$basename}.bam \
O=alignment/RG/{$basename}.RG.bam \
SORT_ORDER=coordinate \
RGID=${count} \
RGLB=Droso-pool-${count} \
RGPL=ILLUMINA \
RGSM=$basename \
RGPU=unit${count} 

rm alignment/{$basename}.bam
# Make QC of alignment
samtools flagstat -@ $THREADS alignment/RG/{$basename}.RG.bam > ${QC}/${basename}.flagstat

mkdir alignment/RG/dedup
mkdir alignment/RG/dedup/metrics
mkdir TEMP
TEMPDIR = 'TEMP'

java -Xmx${RAM} -Djava.io.tmpdir=${TEMPDIR} -jar /home/gene/Tools/picard/build/libs/picard.jar MarkDuplicates \
I=alignment/RG/{$basename}.RG.bam \
O=alignment/RG/dedup/{$basename}.dedup.bam \
M=alignment/RG/dedup/metrics/{$basename} \
OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
CREATE_INDEX=true

# Indel realignment is NOT needed in GATK4
# Do we need it?

# Create a dictionary of the reference genome
java -Xmx${RAM} -Djava.io.tmpdir=${TEMPDIR} -jar /home/gene/Tools/picard/build/libs/picard.jar CreateSequenceDictionary \
R=${GENOME} \
O=${GENOME}.dict

# Indexing 
samtools index alignment/RG/dedup/${basename}.dedup.bam

mkdir VCFs
# Gaplotype calling
# WHY JUST 3g???
java -Xmx3g -jar gatk.jar \
HaplotypeCaller \
-R ${GENOME} \
-I alignment/RG/dedup/${basename}.dedup.bam \
--sample-ploidy # 2 x pool size \
--max-genotype-count \
-O VCFs/${basename}.vcf

# for RG 
count=$count+1
done
