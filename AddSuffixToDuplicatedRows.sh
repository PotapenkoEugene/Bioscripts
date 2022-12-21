#!/bin/bash
file=$1 # text/table file
awk 'NR==FNR && index($0, ">")==1 { a[$0]++ } NR!=FNR && a[$0]>1 { $0=$0"_"(++b[$0]) } NR!=FNR' $file $file
