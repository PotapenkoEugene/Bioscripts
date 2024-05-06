#!/bin/bash
name=$1
fastp -i ${name}1.fastq.gz -I ${name}2.fastq.gz -o ${name}1.trim.fastq.gz -O ${name}2.trim.fastq.gz -w 16
