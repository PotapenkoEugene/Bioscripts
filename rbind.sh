#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 arg1 [arg2 ... argN] output_file_name"
  exit 1
}

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
  usage
fi

echo "INFO: Make sure that all your files has the same header"
echo "INFO: Rbind these files: ${@:1:$#-1}"
echo "INFO: To this file: ${!#}"

echo "INFO: Header saved from the first file"
head -1 $1 > ${!#}
awk 'FNR>1{print}' ${@:1:$#-1} >> ${!#}

