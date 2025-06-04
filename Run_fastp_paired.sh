#!/bin/bash
name=$1
extension=$2
fastp -i ${name}_1.${extension} -I ${name}_2.${extension} -o ${name}_1_trim.fq.gz -O ${name}_2_trim.fq.gz -w 16
