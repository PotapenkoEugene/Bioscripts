#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 arg1 [arg2 ... argN]"
  exit 1
}

# Check if at least 2 arguments are provided
if [ "$#" -lt 2 ]; then
  usage
fi

head -1 $1
awk 'FNR>1{print}' ${@:1:$#}

