#!/bin/bash

vcf=$1
gwasresult=$2
cutline=$3
gff=$4
subpops=$5 # list of samples
position=$6 # chr:start-end
selevar=$7
outprefix=$8
density=300 # svg2png
scale=0.4 # svg2png 

LDBlockShow -InVCF $vcf -SubPop ${subpops} -InGWAS $gwasresult -InGFF $gff -SeleVar ${selevar} -NoShowLDist 35000000 -BlockType 1 -Region $position -OutPut ${outprefix} -NoGeneName -Cutline $cutline
cairosvg -d $density -f png -o ${outprefix}.png ${outprefix}.svg

