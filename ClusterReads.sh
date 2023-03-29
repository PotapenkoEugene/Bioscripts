#!/bin/bash

FASTQ=$1
CPU=$2
IDENTITY=$3
NTOP=$4

# 2fasta
fasta=$(basename $FASTQ .fastq).fasta
seqtk seq -a $FASTQ > $fasta 

# Rename
fastaRE=$(basename $fasta .fasta).RE.fasta
cat $fasta | awk '/^>/{print ">" ++i; next}{print}' > $fastaRE

# Clustering
clusters=$(basename $fastaRE .fasta).clstr
cd-hit-est -T $CPU -M 0 -i $fastaRE -o $(basename $fastaRE .fasta) -c $IDENTITY

# Retrieve sequences by clusters
## Rename cluster file
sed -i "s/Cluster /Cluster_/" $clusters
## Make list of read names for each cluster and retrieve sequences
for i in `seq 0 $(($NTOP-1))`
	do
	echo "Cluster_${i}" >> Cluster.list
	faSomeRecords $clusters Cluster.list Cluster.${i}
	cat Cluster.${i} | tail -n +2 | cut -f2 | cut -f2 -d ' ' | sed 's/>//' | sed 's/\.\.\.//' > Cluster.${i}.list
	faSomeRecords $fastaRE Cluster.${i}.list Cluster.${i}.fasta
	done
