#!/bin/bash

FASTQ=$1
CPU=$2
IDENTITY=$3
NTOP=$4

# TRIM (specific options pasted)
fastqTRIM=$(basename $FASTQ .fastq).trim.fastq
fastp -w 16 -a GATCGGAAGAGCACACGTC -b 35 --length_required 35 -i $FASTQ -o $fastqTRIM

# 2fasta
fasta=$(basename $fastqTRIM .fastq).fasta
seqtk seq -a $fastqTRIM > $fasta 

# Rename
fastaRE=$(basename $fasta .fasta).RE.fasta
cat $fasta | awk '/^>/{print ">" ++i; next}{print}' > $fastaRE

# Clustering
clusters=$(basename $fastaRE .fasta).clstr
cd-hit-est -T $CPU -M 0 -i $fastaRE -o $(basename $fastaRE .fasta) -c $IDENTITY -sc 1

# Count seqs in clusters
echo -e 'Cluster\tNSEQ' > Clusters.stat | awk -F '\t' '/^>/ {if (n>0) print cluster"\t"n; cluster=$0; n=0; next} {n++} END {if (n>0) print cluster"\t"n}' $clusters | sed 's/>//' >> Clusters.stat

# Retrieve sequences by clusters
## Rename cluster file
sed -i "s/Cluster //" $clusters
## Make list of read names for each cluster and retrieve sequences
for i in `seq 0 $(($NTOP-1))`
	do
	echo "${i}" > Cluster.list
	faSomeRecords $clusters Cluster.list Cluster.${i}
	cat Cluster.${i} | tail -n +2 | cut -f2 | cut -f2 -d ' ' | sed 's/>//' | sed 's/\.\.\.//' > Cluster.${i}.list
	faSomeRecords $fastaRE Cluster.${i}.list Cluster.${i}.fasta
	
	# Remove sequences with N
	cat Cluster.${i}.fasta | grep -B1 N | grep '>' | sed 's/>//' > N.list
	faSomeRecords -exclude Cluster.${i}.fasta N.list Cluster.${i}.f.fasta
	
	# Draw Logo
	Rscript `which FastaToLogo.R` Cluster.${i}.f.fasta Cluster.${i}.PWM.tsv Cluster.${i}.LOGO.png

	done
