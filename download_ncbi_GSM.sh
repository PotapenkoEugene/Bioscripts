#!/bin/bash

GSM=$1 
GSMn="$(echo ${GSM} | cut -c 1-$((`echo $GSM | wc -m` - 4)))nnn"

wget https://ftp.ncbi.nlm.nih.gov/geo/samples/${GSMn}/${GSM}/suppl/${GSM}*
