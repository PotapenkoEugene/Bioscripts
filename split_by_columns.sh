#!/bin/bash
# source: https://stackoverflow.com/questions/5265839/split-delimited-file-into-smaller-files-by-column
(($# == 2)) || { echo -e "\nUsage: $0 <file to split> <# columns in each split>\n\n"; exit; }

infile="$1"

inc=$2
ncol=$(awk 'NR==1{print NF}' "$infile")

((inc < ncol)) || { echo -e "\nSplit size >= number of columns\n\n"; exit; }

for((i=0, start=1, end=$inc; i < ncol/inc + 1; i++, start+=inc, end+=inc)); do
  cut -f$start-$end "$infile" > "${infile}.$i" & done


