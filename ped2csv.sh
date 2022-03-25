#!/bin/bash
IN_PED=$1
OUT_CSV=$2
cut -d " " -f 2-2,7- --output-delimiter=, $IN_PED > $OUT_CSV
