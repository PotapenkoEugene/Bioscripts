#!/bin/bash

# Addapted for PE reads
# Source: https://www.biostars.org/p/146069/

SAM=$1
R1=$2
R2=$3

ID=`tail -n1 $SAM | cut -f1`  # gives you the latest mapped read id
LINE1=`grep -n "^@$ID" $R1 | cut -f1 -d:` # last id line (use > for fasta)
LINE2=`grep -n "^@$ID" $R2 | cut -f1 -d:`
TOTAL=`cat $R1 | wc -l` # total lines
echo "scale=5; $LINE1/$TOTAL * 100" | bc  # percentage done
echo "scale=5; $LINE2/$TOTAL * 100" | bc  # percentage done
