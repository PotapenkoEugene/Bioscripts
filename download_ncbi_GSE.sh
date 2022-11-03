#!/bin/bash

GEO=$1 
GEOn="$(echo ${GEO} | cut -c 1-$((`echo $GEO | wc -m` - 4)))nnn"

wget https://ftp.ncbi.nlm.nih.gov/geo/series/${GEOn}/${GEO}/suppl/${GEO}_RAW.tar
