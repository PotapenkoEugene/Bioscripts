#!/bin/bash
# deepTools needed

PEAKS=$1 # one file
SIGNAL=$2 # one or many(sep = ' ')
LABELS=$3 # one or many(sep = ' ')
BEFORE=$4 #bp before left end of the region
AFTER=$5 # bp after right end of the region
SUFFIX=$6
ZMIN=$7 # 0
ZMAX=$8 # 20 is ok (remove outliers
CPU=$9

SORT_REGION='no'
# Define output file
OUTPUT_FILE="ComputeMatrix_${SUFFIX}.gz"

# Check if the output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo "File $OUTPUT_FILE already exists. Skipping the computation."
else
	computeMatrix scale-regions -S $SIGNAL -R $PEAKS -b 3000 -a 3000 -o ComputeMatrix_${SUFFIX}.gz -p $CPU --samplesLabel $LABELS
fi

plotHeatmap -m ComputeMatrix_${SUFFIX}.gz -out ComputeMatrix_${SUFFIX}.png --whatToShow 'heatmap and colorbar' --dpi 300 --boxAroundHeatmaps no --colorList 'white,blue' --interpolationMethod nearest --missingDataColor white --startLabel S --endLabel E --zMin $ZMIN --zMax $ZMAX --xAxisLabel '' --sortRegions $SORT_REGION

